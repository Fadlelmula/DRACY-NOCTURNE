import type { ConversationContext, TurnRole } from "./types.ts";

interface MemoryEntry {
  role: TurnRole;
  content: string;
  createdAt: number;
}

export class ShortTermMemory {
  private readonly entries = new Map<string, MemoryEntry[]>();
  private readonly maxTurns: number;
  private readonly ttlMs: number;

  constructor(maxTurns: number, ttlMs: number) {
    this.maxTurns = maxTurns;
    this.ttlMs = ttlMs;
  }

  append(sessionId: string, role: TurnRole, content: string): void {
    this.cleanup();
    const turns = this.entries.get(sessionId) ?? [];
    turns.push({ role, content, createdAt: Date.now() });
    if (turns.length > this.maxTurns) turns.splice(0, turns.length - this.maxTurns);
    this.entries.set(sessionId, turns);
  }

  get(sessionId: string): Array<{ role: TurnRole; content: string }> {
    this.cleanup();
    return (this.entries.get(sessionId) ?? []).map(({ role, content }) => ({ role, content }));
  }

  clear(sessionId: string): void {
    this.entries.delete(sessionId);
  }

  private cleanup(): void {
    const cutoff = Date.now() - this.ttlMs;
    for (const [sessionId, turns] of this.entries) {
      const active = turns.filter((turn) => turn.createdAt >= cutoff);
      if (active.length === 0) this.entries.delete(sessionId);
      else if (active.length !== turns.length) this.entries.set(sessionId, active);
    }
  }
}

export function assembleMemory(context: ConversationContext, shortTerm: Array<{ role: TurnRole; content: string }>) {
  return {
    shortTerm,
    episodic: context.memories,
    relationship: { values: context.relationships, boundaries: context.boundaries },
    world: {
      chapter: context.chapter_id,
      unlocked: context.flags,
    },
  };
}
