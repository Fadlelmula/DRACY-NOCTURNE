# DRACY: NOCTURNE Backend

Optional, provider-independent conversation service for the post-prologue sandbox. The main game does not require this service.

## Quick start

```bash
npm ci
copy .env.example .env
# Set SESSION_SECRET, then optionally configure AI_BASE_URL/AI_MODEL/AI_API_KEY.
npm start
```

Without provider credentials, the service returns safe scripted fallback replies.

## Scripts

- `npm run dev` — watch mode
- `npm start` — start server
- `npm test` — Node built-in test suite
- `npm run typecheck` — strict TypeScript check

## Security

- No provider key is accepted from or returned to the game client.
- Short-lived signed sessions, exact origin allowlist, body limits, and rate limits are enforced.
- All story context is validated; only authored memories are accepted.
- AI output cannot modify story state and is screened before return.
- Production requires a persistent `SESSION_SECRET` of at least 32 characters.

Full API and deployment notes: [`../docs/ai-backend.md`](../docs/ai-backend.md).
