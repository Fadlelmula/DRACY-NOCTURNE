import test from "node:test";
import assert from "node:assert/strict";
import { AuthService } from "../src/auth.ts";
import { loadConfig, type ServerConfig } from "../src/config.ts";

function config(): ServerConfig {
  return loadConfig({ SESSION_SECRET: "x".repeat(32), NODE_ENV: "test" });
}

test("issues and verifies a signed session token", () => {
  const auth = new AuthService(config());
  const { token } = auth.issueSession("a".repeat(32));
  const verified = auth.verifyToken(token);
  assert.ok(verified);
  assert.equal(verified.sid.length > 0, true);
  assert.equal(verified.installHash.length, 64);
});

test("rejects tampered tokens", () => {
  const auth = new AuthService(config());
  const { token } = auth.issueSession("b".repeat(32));
  const [encoded, signature] = token.split(".");
  const tampered = `${encoded}x.${signature}`;
  assert.equal(auth.verifyToken(tampered), null);
  assert.equal(auth.verifyToken("not-a-token"), null);
});

test("rejects expired sessions", () => {
  const expiredConfig = { ...config(), sessionTtlSeconds: -1 };
  const auth = new AuthService(expiredConfig);
  const { token } = auth.issueSession("c".repeat(32));
  assert.equal(auth.verifyToken(token), null);
});
