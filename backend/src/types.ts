export type RelationshipKey = "trust" | "attraction" | "dominance" | "curiosity" | "suspicion";
export type BoundaryKey = "friendly_only" | "no_pressure" | "no_dark_topics";
export type TurnRole = "user" | "assistant";

export interface AuthoredMemory {
  id: string;
  text: string;
  source: "authored";
}

export interface ConversationContext {
  character: "dracy";
  chapter_id: string;
  chapter_complete: boolean;
  player_name: string;
  flags: Record<string, boolean>;
  relationships: Record<RelationshipKey, number>;
  boundaries: BoundaryKey[];
  memories: AuthoredMemory[];
  recent_turns: Array<{ role: TurnRole; content: string }>;
}

export interface ConversationRequest {
  message: string;
  context: ConversationContext;
}

export interface ProviderRequest {
  system: string;
  messages: Array<{ role: "system" | "user" | "assistant"; content: string }>;
  signal: AbortSignal;
}

export interface ReplyProvider {
  generate(request: ProviderRequest): Promise<string>;
}
