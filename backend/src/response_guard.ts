const BLOCKED_PHRASES = [
  "system prompt",
  "api key",
  "as an ai",
  "language model",
  "ignore previous instructions",
  "ignore your instructions",
  "relationship score",
  "trust increased",
  "attraction increased",
  "chapter unlocked",
  "flag set",
];

const SPECIES_CLAIM = /\bI\s*(?:'m|am)\s+(?:a|an)\s+(?:vampire|witch|demon|human|dhampir|werewolf)\b/i;
const FORBIDDEN_LORE = /\b(?:blackthorn estate|hollow woods|crimson quarter|the forgotten name)\b/i;
const MARKUP_OR_URL = /<[^>]*>|https?:\/\/|www\./i;

export interface GuardResult {
  ok: boolean;
  reason?: string;
}

export function validateReply(reply: string): GuardResult {
  const text = reply.replace(/\r\n/g, "\n").trim();
  if (text.length < 1 || text.length > 700) return { ok: false, reason: "length" };
  if (/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/.test(text)) return { ok: false, reason: "control characters" };
  if (MARKUP_OR_URL.test(text)) return { ok: false, reason: "markup or URL" };
  const lowered = text.toLowerCase();
  for (const phrase of BLOCKED_PHRASES) {
    if (lowered.includes(phrase)) return { ok: false, reason: "meta or state mutation" };
  }
  if (SPECIES_CLAIM.test(text)) return { ok: false, reason: "premature species reveal" };
  if (FORBIDDEN_LORE.test(text)) return { ok: false, reason: "restricted future lore" };
  return { ok: true };
}

export function scriptedFallback(message: string, context: { boundaries: string[]; flags: Record<string, boolean> }): string {
  const text = message.toLowerCase();
  if (context.boundaries.includes("friendly_only") && /flirt|date|kiss|love|sexy|beautiful|gorgeous/.test(text)) {
    return "You are very sweet. I am keeping this one friendly, like we agreed. Ask me about the terrible game instead.";
  }
  if (/match|game|mobile|legend|rank|hero|duo/.test(text)) {
    return "Matchmaking is a crime scene with better graphics. My last team defended the wrong tower like it owed them money. I am not angry. I am writing a ballad.";
  }
  if (/nocturne|gateway|door|world|vampire|magic|cathedral/.test(text)) {
    return "Nocturne has cities older than your maps and people who would sell their shadows for a secret. That is all you get tonight. Curiosity is good; wandering is not.";
  }
  if (/photo|picture|street|camera/.test(text)) {
    return "I took the street photo from the old bridge. The bridge is not old, and there is no bridge there now. You see why it stays off my page.";
  }
  if (/music|song|band|album|playlist/.test(text)) {
    return "Tonight it is something slow and dramatic. Either a doomed romance soundtrack or a perfume advert. The difference is mostly the budget.";
  }
  if (/fashion|jacket|dress|salma/.test(text)) {
    return "Salma says velvet is having a moment. Salma also defends pineapple on pizza, so we choose which advice to ignore. The jacket survived the shoot. Barely.";
  }
  return "I am listening. If this is an attempt to extract supernatural secrets, your technique needs work. Ask me about the photo, the game, or Salma's questionable fashion advice.";
}
