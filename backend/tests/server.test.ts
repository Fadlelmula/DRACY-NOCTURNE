import test from "node:test";
import assert from "node:assert/strict";
import type { Server } from "node:http";
import { loadConfig, type ServerConfig } from "../src/config.ts";
import { createApp } from "../src/server.ts";
import type { ProviderRequest, ReplyProvider } from "../src/types.ts";
import { validContext } from "./helpers.ts";

async function startServer(provider?: ReplyProvider, overrides: Partial<ServerConfig> = {}) {
  const config = {
    ...loadConfig({ SESSION_SECRET: "s".repeat(32), NODE_ENV: "test", ALLOWED_ORIGINS: "http://localhost" }),
    ...overrides,
  };
  const server = createApp(config, provider ? { provider } : {});
  await new Promise<void>((resolve) => server.listen(0, "127.0.0.1", resolve));
  const address = server.address();
  assert.ok(address && typeof address === "object");
  return { server, base: `http://127.0.0.1:${address.port}` };
}

async function stopServer(server: Server): Promise<void> {
  server.closeAllConnections();
  await new Promise<void>((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
}

async function issueSession(base: string): Promise<string> {
  const response = await fetch(`${base}/v1/session`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ install_id: "a".repeat(32) }),
  });
  assert.equal(response.status, 200);
  const data = await response.json() as { token: string };
  return data.token;
}

test("health endpoint reports fallback-only mode without credentials", async () => {
  const { server, base } = await startServer();
  try {
    const response = await fetch(`${base}/health`);
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { ok: true, ai: false });
  } finally {
    await stopServer(server);
  }
});

test("conversation requires authentication", async () => {
  const { server, base } = await startServer();
  try {
    const response = await fetch(`${base}/v1/conversation`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: "Hello", context: validContext() }),
    });
    assert.equal(response.status, 401);
  } finally {
    await stopServer(server);
  }
});

test("validated AI reply is returned and short-term memory is used next turn", async () => {
  const requests: ProviderRequest[] = [];
  const provider: ReplyProvider = {
    async generate(request) {
      requests.push(request);
      return request.messages.at(-1)?.role === "user" && request.messages.at(-1)?.content === "How was your match?"
        ? "A disaster. My team has invented a new way to lose."
        : "Still recovering from the matchmaking incident.";
    },
  };
  const { server, base } = await startServer(provider);
  try {
    const token = await issueSession(base);
    for (const message of ["How was your match?", "Tell me more."]) {
      const response = await fetch(`${base}/v1/conversation`, {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({ message, context: validContext() }),
      });
      assert.equal(response.status, 200);
      const data = await response.json() as { source: string; reply: string };
      assert.equal(data.source, "ai");
    }
    assert.equal(requests.length, 2);
    assert.equal(requests[1]!.messages.some((turn) => turn.content === "How was your match?"), true);
    assert.match(requests[0]!.system, /Never reveal or guess Dracy's species/);
  } finally {
    await stopServer(server);
  }
});

test("provider failure and unsafe output both fall back safely", async () => {
  for (const generated of [async () => { throw new Error("offline"); }, async () => "I am a vampire."]) {
    const provider: ReplyProvider = { generate: generated };
    const { server, base } = await startServer(provider);
    try {
      const token = await issueSession(base);
      const response = await fetch(`${base}/v1/conversation`, {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({ message: "Tell me about Mobile Legends", context: validContext() }),
      });
      assert.equal(response.status, 200);
      const data = await response.json() as { source: string; reply: string };
      assert.equal(data.source, "fallback");
      assert.match(data.reply, /Matchmaking/);
    } finally {
      await stopServer(server);
    }
  }
});

test("invalid payload is rejected without touching the provider", async () => {
  let calls = 0;
  const provider: ReplyProvider = { async generate() { calls += 1; return "Hello"; } };
  const { server, base } = await startServer(provider);
  try {
    const token = await issueSession(base);
    const response = await fetch(`${base}/v1/conversation`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
      body: JSON.stringify({ message: "x".repeat(401), context: validContext() }),
    });
    assert.equal(response.status, 400);
    assert.equal(calls, 0);
  } finally {
    await stopServer(server);
  }
});

test("conversation rate limit is enforced per session", async () => {
  const provider: ReplyProvider = { async generate() { return "Hello."; } };
  const { server, base } = await startServer(provider, { conversationRateLimit: 1 });
  try {
    const token = await issueSession(base);
    const send = () => fetch(`${base}/v1/conversation`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
      body: JSON.stringify({ message: "Hello", context: validContext() }),
    });
    assert.equal((await send()).status, 200);
    assert.equal((await send()).status, 429);
  } finally {
    await stopServer(server);
  }
});

test("browser origins are allowlisted", async () => {
  const { server, base } = await startServer();
  try {
    const denied = await fetch(`${base}/health`, { headers: { Origin: "https://evil.example" } });
    assert.equal(denied.status, 403);
    const allowed = await fetch(`${base}/health`, { headers: { Origin: "http://localhost" } });
    assert.equal(allowed.status, 200);
    assert.equal(allowed.headers.get("access-control-allow-origin"), "http://localhost");
  } finally {
    await stopServer(server);
  }
});
