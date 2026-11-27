import type { ConversationContext } from "../src/types.ts";

export function validContext(): ConversationContext {
  return {
    character: "dracy",
    chapter_id: "prologue",
    chapter_complete: true,
    player_name: "Sam",
    flags: { gateway_discovered: true, dracy_secret_partially_revealed: true },
    relationships: { trust: 4, attraction: 1, dominance: 2, curiosity: 5, suspicion: 3 },
    boundaries: ["no_pressure"],
    memories: [{ id: "mem_player_name", text: "The player shared their first name.", source: "authored" }],
    recent_turns: [],
  };
}
