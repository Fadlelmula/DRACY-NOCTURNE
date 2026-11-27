import type { BoundaryKey, ConversationContext, ConversationRequest, RelationshipKey } from "./types.ts";

const RELATIONSHIP_KEYS: RelationshipKey[] = ["trust", "attraction", "dominance", "curiosity", "suspicion"];
const BOUNDARY_KEYS: BoundaryKey[] = ["friendly_only", "no_pressure", "no_dark_topics"];
const ALLOWED_FLAGS = new Set([
  "dracy_shared_first_photo",
  "respected_dracy_busy",
  "player_shared_name",
  "player_suspects_supernatural_activity",
  "gateway_discovered",
  "dracy_secret_partially_revealed",
  "promised_to_meet",
  "dracy_felt_safe",
]);
const SAFE_ID = /^[A-Za-z0-9_:-]{1,96}$/;
const INSTALL_ID = /^[a-f0-9]{32}$/i;

export class ValidationError extends Error {}

export function validateInstallId(value: unknown): string {
  if (typeof value !== "string" || !INSTALL_ID.test(value)) {
    throw new ValidationError("install_id must be a 32-character hexadecimal identifier");
  }
  return value.toLowerCase();
}

export function validateConversationRequest(value: unknown): ConversationRequest {
  if (!isRecord(value)) throw new ValidationError("Request body must be an object");
  const message = cleanText(value.message, 1, 400, "message");
  const context = validateContext(value.context);
  return { message, context };
}

export function validateContext(value: unknown): ConversationContext {
  if (!isRecord(value)) throw new ValidationError("context must be an object");
  if (value.character !== "dracy") throw new ValidationError("Unsupported character");
  const chapterId = cleanText(value.chapter_id, 1, 64, "chapter_id");
  if (!/^[a-z0-9_]+$/.test(chapterId)) throw new ValidationError("Invalid chapter_id");
  if (typeof value.chapter_complete !== "boolean") throw new ValidationError("chapter_complete must be boolean");
  const playerName = cleanText(value.player_name || "Player", 1, 24, "player_name");
  const flags = validateFlags(value.flags);
  const relationships = validateRelationships(value.relationships);
  const boundaries = validateBoundaries(value.boundaries);
  const memories = validateMemories(value.memories);
  const recentTurns = validateRecentTurns(value.recent_turns);
  return {
    character: "dracy",
    chapter_id: chapterId,
    chapter_complete: value.chapter_complete,
    player_name: playerName,
    flags,
    relationships,
    boundaries,
    memories,
    recent_turns: recentTurns,
  };
}

function validateFlags(value: unknown): Record<string, boolean> {
  if (!isRecord(value)) throw new ValidationError("flags must be an object");
  const result: Record<string, boolean> = {};
  for (const [key, flag] of Object.entries(value)) {
    if (!ALLOWED_FLAGS.has(key)) continue;
    if (typeof flag !== "boolean") throw new ValidationError("Story flags must be boolean");
    result[key] = flag;
  }
  return result;
}

function validateRelationships(value: unknown): Record<RelationshipKey, number> {
  if (!isRecord(value)) throw new ValidationError("relationships must be an object");
  const result = {} as Record<RelationshipKey, number>;
  for (const key of RELATIONSHIP_KEYS) {
    const amount = value[key];
    if (typeof amount !== "number" || !Number.isInteger(amount) || amount < 0 || amount > 10) {
      throw new ValidationError("Relationship values must be integers from 0 to 10");
    }
    result[key] = amount;
  }
  return result;
}

function validateBoundaries(value: unknown): BoundaryKey[] {
  if (!Array.isArray(value) || value.length > BOUNDARY_KEYS.length) throw new ValidationError("Invalid boundaries");
  const result = new Set<BoundaryKey>();
  for (const boundary of value) {
    if (typeof boundary !== "string" || !BOUNDARY_KEYS.includes(boundary as BoundaryKey)) {
      throw new ValidationError("Unknown boundary");
    }
    result.add(boundary as BoundaryKey);
  }
  return [...result];
}

function validateMemories(value: unknown): ConversationContext["memories"] {
  if (!Array.isArray(value) || value.length > 20) throw new ValidationError("Invalid memories");
  const ids = new Set<string>();
  return value.map((memory) => {
    if (!isRecord(memory) || typeof memory.id !== "string" || !SAFE_ID.test(memory.id)) {
      throw new ValidationError("Invalid memory id");
    }
    if (memory.source !== "authored") throw new ValidationError("Only authored memories are accepted");
    if (ids.has(memory.id)) throw new ValidationError("Duplicate memory id");
    ids.add(memory.id);
    return { id: memory.id, text: cleanText(memory.text, 1, 280, "memory text"), source: "authored" as const };
  });
}

function validateRecentTurns(value: unknown): ConversationContext["recent_turns"] {
  if (!Array.isArray(value) || value.length > 12) throw new ValidationError("Invalid recent_turns");
  return value.map((turn) => {
    if (!isRecord(turn) || (turn.role !== "user" && turn.role !== "assistant")) {
      throw new ValidationError("Invalid conversation role");
    }
    return { role: turn.role, content: cleanText(turn.content, 1, 700, "turn content") };
  });
}

function cleanText(value: unknown, min: number, max: number, field: string): string {
  if (typeof value !== "string") throw new ValidationError(`${field} must be text`);
  const text = value.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "").trim();
  if (text.length < min || text.length > max) throw new ValidationError(`${field} has an invalid length`);
  return text;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
