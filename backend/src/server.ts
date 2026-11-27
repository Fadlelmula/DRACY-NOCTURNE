import { createServer, type IncomingMessage, type Server, type ServerResponse } from "node:http";
import { randomUUID } from "node:crypto";
import type { ServerConfig } from "./config.ts";
import { AuthService } from "./auth.ts";
import { RateLimiter } from "./rate_limit.ts";
import { ShortTermMemory, assembleMemory } from "./memory.ts";
import { validateConversationRequest, validateInstallId, ValidationError } from "./validation.ts";
import { buildProviderMessages, buildSystemPrompt } from "./prompt.ts";
import { OpenAICompatibleProvider, DisabledProvider } from "./provider.ts";
import { scriptedFallback, validateReply } from "./response_guard.ts";
import type { ReplyProvider } from "./types.ts";

interface ServerDependencies {
  provider?: ReplyProvider;
}

export function createApp(config: ServerConfig, dependencies: ServerDependencies = {}): Server {
  const auth = new AuthService(config);
  const memory = new ShortTermMemory(12, config.memoryTtlSeconds * 1000);
  const sessionLimiter = new RateLimiter(config.sessionRateLimit, config.sessionRateLimit / 60);
  const conversationLimiter = new RateLimiter(config.conversationRateLimit, config.conversationRateLimit / 60);
  const provider = dependencies.provider ?? (config.provider.enabled ? new OpenAICompatibleProvider(config) : new DisabledProvider());

  const server = createServer(async (request, response) => {
    const requestId = randomUUID();
    try {
      applySecurityHeaders(response);
      const origin = request.headers.origin;
      if (origin && !isOriginAllowed(origin, config.allowedOrigins)) {
        sendJson(response, 403, { ok: false, error: "Origin not allowed", request_id: requestId });
        return;
      }
      if (origin) {
        response.setHeader("Access-Control-Allow-Origin", origin);
        response.setHeader("Vary", "Origin");
      }
      if (request.method === "OPTIONS") {
        response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.writeHead(204);
        response.end();
        return;
      }
      const path = new URL(request.url ?? "/", "http://localhost").pathname;
      if (request.method === "GET" && path === "/health") {
        sendJson(response, 200, { ok: true, ai: config.provider.enabled });
        return;
      }
      if (request.method !== "POST") {
        sendJson(response, 404, { ok: false, error: "Not found", request_id: requestId });
        return;
      }
      if (path === "/v1/session") {
        await handleSession(request, response, config, auth, sessionLimiter, requestId);
        return;
      }
      if (path === "/v1/conversation") {
        await handleConversation(request, response, config, auth, conversationLimiter, memory, provider, requestId);
        return;
      }
      sendJson(response, 404, { ok: false, error: "Not found", request_id: requestId });
    } catch (error) {
      const message = error instanceof ValidationError ? error.message : error instanceof BodyLimitError ? error.message : "Internal server error";
      const status = error instanceof ValidationError ? 400 : error instanceof BodyLimitError ? 413 : 500;
      if (status === 500) console.error(`[${requestId}] request failed`, error instanceof Error ? error.name : "unknown error");
      sendJson(response, status, { ok: false, error: message, request_id: requestId });
    }
  });
  server.headersTimeout = 15_000;
  server.requestTimeout = 20_000;
  server.keepAliveTimeout = 5_000;
  return server;
}

async function handleSession(
  request: IncomingMessage,
  response: ServerResponse,
  config: ServerConfig,
  auth: AuthService,
  limiter: RateLimiter,
  requestId: string,
): Promise<void> {
  const ip = clientIp(request);
  const limit = limiter.check(`session:${ip}`);
  if (!limit.allowed) {
    response.setHeader("Retry-After", String(limit.retryAfter));
    sendJson(response, 429, { ok: false, error: "Too many session requests", request_id: requestId });
    return;
  }
  const body = await readJsonBody(request, config.maxBodyBytes);
  const installId = validateInstallId(isRecord(body) ? body.install_id : undefined);
  const session = auth.issueSession(installId);
  sendJson(response, 200, { ok: true, ...session, request_id: requestId });
}

async function handleConversation(
  request: IncomingMessage,
  response: ServerResponse,
  config: ServerConfig,
  auth: AuthService,
  limiter: RateLimiter,
  memory: ShortTermMemory,
  provider: ReplyProvider,
  requestId: string,
): Promise<void> {
  const authorization = request.headers.authorization;
  if (!authorization?.startsWith("Bearer ")) {
    sendJson(response, 401, { ok: false, error: "Authentication required", request_id: requestId });
    return;
  }
  const session = auth.verifyToken(authorization.slice(7).trim());
  if (!session) {
    sendJson(response, 401, { ok: false, error: "Invalid or expired session", request_id: requestId });
    return;
  }
  const limit = limiter.check(`conversation:${session.sid}`);
  if (!limit.allowed) {
    response.setHeader("Retry-After", String(limit.retryAfter));
    sendJson(response, 429, { ok: false, error: "Conversation rate limit reached", request_id: requestId });
    return;
  }
  const body = await readJsonBody(request, config.maxBodyBytes);
  const parsed = validateConversationRequest(body);
  const layers = assembleMemory(parsed.context, memory.get(session.sid));
  const system = buildSystemPrompt(parsed.context);
  const messages = buildProviderMessages(system, layers.shortTerm, parsed.message);
  let reply = "";
  let source: "ai" | "fallback" = "ai";
  try {
    const candidate = await provider.generate({ system, messages, signal: AbortSignal.timeout(config.provider.timeoutMs) });
    const guard = validateReply(candidate);
    if (!guard.ok) throw new Error(`Reply rejected: ${guard.reason}`);
    reply = candidate.trim();
  } catch {
    source = "fallback";
    reply = scriptedFallback(parsed.message, parsed.context);
  }
  memory.append(session.sid, "user", parsed.message);
  memory.append(session.sid, "assistant", reply);
  sendJson(response, 200, { ok: true, reply, source, request_id: requestId });
}

class BodyLimitError extends Error {}

async function readJsonBody(request: IncomingMessage, maxBytes: number): Promise<unknown> {
  const chunks: Buffer[] = [];
  let size = 0;
  for await (const chunk of request) {
    const buffer = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
    size += buffer.length;
    if (size > maxBytes) throw new BodyLimitError("Request body is too large");
    chunks.push(buffer);
  }
  try {
    return JSON.parse(Buffer.concat(chunks).toString("utf8")) as unknown;
  } catch {
    throw new ValidationError("Request body must be valid JSON");
  }
}

function applySecurityHeaders(response: ServerResponse): void {
  response.setHeader("X-Content-Type-Options", "nosniff");
  response.setHeader("Cache-Control", "no-store");
  response.setHeader("Referrer-Policy", "no-referrer");
  response.setHeader("X-Frame-Options", "DENY");
}

function isOriginAllowed(origin: string, allowed: string[]): boolean {
  return allowed.includes(origin.replace(/\/$/, ""));
}

function clientIp(request: IncomingMessage): string {
  return request.socket.remoteAddress ?? "unknown";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function sendJson(response: ServerResponse, status: number, payload: unknown): void {
  if (response.writableEnded) return;
  const body = JSON.stringify(payload);
  response.writeHead(status, { "Content-Type": "application/json; charset=utf-8", "Content-Length": Buffer.byteLength(body) });
  response.end(body);
}
