import { randomBytes } from "node:crypto";

export interface ServerConfig {
  host: string;
  port: number;
  production: boolean;
  sessionSecret: string;
  allowedOrigins: string[];
  maxBodyBytes: number;
  sessionTtlSeconds: number;
  memoryTtlSeconds: number;
  sessionRateLimit: number;
  conversationRateLimit: number;
  provider: {
    enabled: boolean;
    baseUrl: string;
    model: string;
    apiKey: string;
    timeoutMs: number;
  };
}

export function loadConfig(env: NodeJS.ProcessEnv = process.env): ServerConfig {
  const production = env.NODE_ENV === "production";
  const configuredSecret = env.SESSION_SECRET?.trim() ?? "";
  const sessionSecret = configuredSecret || randomBytes(32).toString("hex");
  if (production && configuredSecret.length < 32) {
    throw new Error("SESSION_SECRET must contain at least 32 characters in production");
  }
  const baseUrl = (env.AI_BASE_URL ?? "").trim().replace(/\/$/, "");
  const model = (env.AI_MODEL ?? "").trim();
  const apiKey = (env.AI_API_KEY ?? "").trim();
  const providerEnabled = Boolean(baseUrl && model && apiKey);
  if (providerEnabled && !isAllowedProviderUrl(baseUrl)) {
    throw new Error("AI_BASE_URL must use HTTPS, except for loopback development URLs");
  }
  return {
    host: env.HOST?.trim() || "127.0.0.1",
    port: parsePositiveInt(env.PORT, 8787),
    production,
    sessionSecret,
    allowedOrigins: (env.ALLOWED_ORIGINS ?? "")
      .split(",")
      .map((value) => value.trim().replace(/\/$/, ""))
      .filter(Boolean),
    maxBodyBytes: 32_768,
    sessionTtlSeconds: 15 * 60,
    memoryTtlSeconds: 30 * 60,
    sessionRateLimit: parsePositiveInt(env.SESSION_RATE_LIMIT, 10),
    conversationRateLimit: parsePositiveInt(env.CONVERSATION_RATE_LIMIT, 30),
    provider: {
      enabled: providerEnabled,
      baseUrl,
      model,
      apiKey,
      timeoutMs: 12_000,
    },
  };
}

function parsePositiveInt(value: string | undefined, fallback: number): number {
  const parsed = Number(value);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : fallback;
}

function isAllowedProviderUrl(value: string): boolean {
  try {
    const url = new URL(value);
    if (url.protocol === "https:") return true;
    return url.protocol === "http:" && (url.hostname === "127.0.0.1" || url.hostname === "localhost" || url.hostname === "::1");
  } catch {
    return false;
  }
}
