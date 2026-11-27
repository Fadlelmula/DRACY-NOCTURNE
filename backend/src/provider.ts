import type { ProviderRequest, ReplyProvider } from "./types.ts";
import type { ServerConfig } from "./config.ts";

export class OpenAICompatibleProvider implements ReplyProvider {
  private readonly config: ServerConfig;

  constructor(config: ServerConfig) {
    this.config = config;
  }

  async generate(request: ProviderRequest): Promise<string> {
    if (!this.config.provider.enabled) throw new Error("AI provider is not configured");
    const response = await fetch(`${this.config.provider.baseUrl}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.config.provider.apiKey}`,
      },
      body: JSON.stringify({
        model: this.config.provider.model,
        messages: request.messages,
        temperature: 0.75,
        max_tokens: 220,
      }),
      signal: request.signal,
    });
    if (!response.ok) throw new Error(`Provider returned HTTP ${response.status}`);
    const data: unknown = await response.json();
    if (!isRecord(data) || !Array.isArray(data.choices)) throw new Error("Invalid provider response");
    const first = data.choices[0];
    if (!isRecord(first) || !isRecord(first.message) || typeof first.message.content !== "string") {
      throw new Error("Provider returned no text");
    }
    return first.message.content;
  }
}

export class DisabledProvider implements ReplyProvider {
  async generate(): Promise<string> {
    throw new Error("AI provider is disabled");
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
