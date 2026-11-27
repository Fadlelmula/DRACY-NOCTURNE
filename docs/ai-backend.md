# Optional AI backend

## Purpose

The backend powers only optional post-prologue conversation. The authored prologue and all save/story systems work without it.

## Run

```bash
cd backend
npm ci
copy .env.example .env
```

Set at minimum:

```dotenv
SESSION_SECRET=<at least 32 random characters>
ALLOWED_ORIGINS=http://localhost,http://127.0.0.1
```

For a real OpenAI-compatible provider:

```dotenv
AI_BASE_URL=https://api.openai.com/v1
AI_MODEL=<provider model>
AI_API_KEY=<server-only secret>
```

Then:

```bash
npm start
```

The server prints whether a provider is configured. If not, it returns scripted fallback replies and the game remains fully usable.

## Endpoints

### `GET /health`

Returns service health and whether a provider is configured. No secrets are returned.

### `POST /v1/session`

```json
{"install_id":"<32 hexadecimal characters>"}
```

Returns a signed short-lived bearer token. The install ID is a pseudonymous local identifier, not an account.

### `POST /v1/conversation`

Header:

```text
Authorization: Bearer <session token>
Content-Type: application/json
```

Body:

```json
{
  "message": "How was your match?",
  "context": {
    "character": "dracy",
    "chapter_id": "prologue",
    "chapter_complete": true,
    "player_name": "Sam",
    "flags": {"gateway_discovered": true},
    "relationships": {
      "trust": 4, "attraction": 1, "dominance": 2,
      "curiosity": 5, "suspicion": 3
    },
    "boundaries": ["no_pressure"],
    "memories": [
      {"id":"mem_player_name","text":"The player shared their first name.","source":"authored"}
    ],
    "recent_turns": []
  }
}
```

Response:

```json
{
  "ok": true,
  "reply": "A disaster. My team invented a new way to lose.",
  "source": "ai",
  "request_id": "..."
}
```

`source` is `ai` or `fallback`.

## Safety layers

1. **Transport/origin:** exact browser-origin allowlist; native requests without `Origin` are accepted.
2. **Authentication:** HMAC-signed token plus server-side session record and expiry.
3. **Abuse controls:** bounded request body, per-IP session limiter, per-session conversation limiter, server timeouts.
4. **Input validation:** closed character/flag/boundary sets, integer relationship ranges, authored-only memories, control-character stripping.
5. **Prompt isolation:** approved canon, verified state, four memory layers, explicit no-species/no-future-lore/no-state-mutation rules.
6. **Output validation:** length, control characters, markup/URLs, meta prompts, species claims, future locations, and state-mutation phrases.
7. **Fallback:** provider errors, timeouts, invalid JSON, and rejected replies return safe authored dialogue.
8. **Client defense:** the Godot client repeats basic reply checks and never applies AI output to `GameState`.

## Memory behavior

- Short-term turns are in memory only, bounded to 12 turns and a 30-minute TTL.
- Episodic memories must be supplied with `source: "authored"`.
- Relationship values and boundaries are read-only context.
- World knowledge is restricted to approved canon and unlocked flags.
- Client-supplied `recent_turns` are validated but not used as provider history; the server uses its own bounded memory to reduce fabrication risk.
- Restarting the backend clears short-term memory and invalidates sessions if no persistent secret/store is configured.

## Production notes

Before public deployment:

- Use HTTPS and a reverse proxy.
- Set a strong persistent `SESSION_SECRET`; production startup rejects short secrets.
- Restrict `ALLOWED_ORIGINS` to exact game/web origins.
- Add distributed rate limiting and session storage if running multiple instances.
- Add PostgreSQL only when persistent/cloud memory is actually required.
- Add provider cost budgets, observability with redaction, and moderation appropriate to the deployment region.
- Never log authorization headers, provider keys, or full conversation bodies.
- Review provider data-retention settings before enabling a third-party model.

M01 intentionally has no database, account system, or complete long-term memory implementation.

## Tests

```bash
npm test
npm run typecheck
```

The suite uses injected fake providers to verify successful replies, short-term continuity, provider failure fallback, unsafe-output fallback, authentication, payload validation, rate limiting, CORS, memory bounds, token tampering, and expiry. No live provider credentials are required.
