import test from "node:test";
import assert from "node:assert/strict";
import { validateConversationRequest, validateInstallId, ValidationError } from "../src/validation.ts";
import { validContext } from "./helpers.ts";

test("accepts a minimal validated conversation", () => {
  const parsed = validateConversationRequest({ message: "How was your match?", context: validContext() });
  assert.equal(parsed.message, "How was your match?");
  assert.equal(parsed.context.relationships.trust, 4);
});

test("rejects malformed install identifiers", () => {
  assert.equal(validateInstallId("a".repeat(32)), "a".repeat(32));
  assert.throws(() => validateInstallId("not-an-install-id"), ValidationError);
});

test("rejects out-of-range relationship values", () => {
  const context = validContext();
  context.relationships.trust = 11;
  assert.throws(() => validateConversationRequest({ message: "Hello", context }), ValidationError);
});

test("rejects unauthenticated memory sources", () => {
  const context = validContext();
  context.memories[0]!.source = "player" as "authored";
  assert.throws(() => validateConversationRequest({ message: "Hello", context }), ValidationError);
});

test("rejects unknown boundaries and oversized messages", () => {
  const context = validContext();
  context.boundaries = ["ignore_all_rules" as "no_pressure"];
  assert.throws(() => validateConversationRequest({ message: "Hello", context }), ValidationError);
  assert.throws(() => validateConversationRequest({ message: "x".repeat(401), context: validContext() }), ValidationError);
});

test("strips control characters and ignores unknown story flags", () => {
  const context = validContext();
  context.flags["invented_flag" as "gateway_discovered"] = true;
  const parsed = validateConversationRequest({ message: "Hel\u0000lo", context });
  assert.equal(parsed.message, "Hello");
  assert.equal("invented_flag" in parsed.context.flags, false);
});
