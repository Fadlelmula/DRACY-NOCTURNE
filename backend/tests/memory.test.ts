import test from "node:test";
import assert from "node:assert/strict";
import { RateLimiter } from "../src/rate_limit.ts";
import { ShortTermMemory, assembleMemory } from "../src/memory.ts";
import { validContext } from "./helpers.ts";

test("rate limiter enforces a bounded burst", () => {
  const limiter = new RateLimiter(2, 1);
  assert.equal(limiter.check("client", 1000).allowed, true);
  assert.equal(limiter.check("client", 1000).allowed, true);
  const blocked = limiter.check("client", 1000);
  assert.equal(blocked.allowed, false);
  assert.equal(blocked.retryAfter >= 1, true);
  assert.equal(limiter.check("client", 2000).allowed, true);
});

test("short-term memory is bounded and clearable", () => {
  const memory = new ShortTermMemory(2, 60_000);
  memory.append("session", "user", "one");
  memory.append("session", "assistant", "two");
  memory.append("session", "user", "three");
  assert.deepEqual(memory.get("session"), [
    { role: "assistant", content: "two" },
    { role: "user", content: "three" },
  ]);
  memory.clear("session");
  assert.deepEqual(memory.get("session"), []);
});

test("memory assembly keeps all four layers separate", () => {
  const layers = assembleMemory(validContext(), [{ role: "user", content: "recent" }]);
  assert.equal(layers.shortTerm.length, 1);
  assert.equal(layers.episodic.length, 1);
  assert.equal(layers.relationship.values.trust, 4);
  assert.equal(layers.world.unlocked.gateway_discovered, true);
});
