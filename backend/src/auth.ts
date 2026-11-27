import { createHmac, randomBytes, timingSafeEqual } from "node:crypto";
import type { ServerConfig } from "./config.ts";

interface SessionRecord {
  installHash: string;
  expiresAt: number;
}

interface TokenPayload {
  sid: string;
  exp: number;
}

export class AuthService {
  private readonly sessions = new Map<string, SessionRecord>();
  private readonly config: ServerConfig;

  constructor(config: ServerConfig) {
    this.config = config;
  }

  issueSession(installId: string): { token: string; expires_in: number } {
    this.cleanup();
    const sid = randomBytes(24).toString("base64url");
    const expiresAt = Date.now() + this.config.sessionTtlSeconds * 1000;
    this.sessions.set(sid, {
      installHash: this.hashInstall(installId),
      expiresAt,
    });
    const payload: TokenPayload = { sid, exp: Math.floor(expiresAt / 1000) };
    return { token: this.sign(payload), expires_in: this.config.sessionTtlSeconds };
  }

  verifyToken(token: string): { sid: string; installHash: string } | null {
    const parts = token.split(".");
    if (parts.length !== 2) return null;
    const [encoded, signature] = parts;
    if (!encoded || !signature) return null;
    const expected = this.signatureFor(encoded);
    const providedBuffer = Buffer.from(signature, "base64url");
    const expectedBuffer = Buffer.from(expected, "base64url");
    if (providedBuffer.length !== expectedBuffer.length || !timingSafeEqual(providedBuffer, expectedBuffer)) return null;
    let payload: TokenPayload;
    try {
      payload = JSON.parse(Buffer.from(encoded, "base64url").toString("utf8")) as TokenPayload;
    } catch {
      return null;
    }
    if (!payload || typeof payload.sid !== "string" || typeof payload.exp !== "number") return null;
    if (payload.exp * 1000 <= Date.now()) return null;
    const session = this.sessions.get(payload.sid);
    if (!session || session.expiresAt <= Date.now()) {
      this.sessions.delete(payload.sid);
      return null;
    }
    return { sid: payload.sid, installHash: session.installHash };
  }

  private sign(payload: TokenPayload): string {
    const encoded = Buffer.from(JSON.stringify(payload), "utf8").toString("base64url");
    return `${encoded}.${this.signatureFor(encoded)}`;
  }

  private signatureFor(encoded: string): string {
    return createHmac("sha256", this.config.sessionSecret).update(encoded).digest("base64url");
  }

  private hashInstall(installId: string): string {
    return createHmac("sha256", this.config.sessionSecret).update(installId).digest("hex");
  }

  private cleanup(): void {
    const now = Date.now();
    for (const [sid, session] of this.sessions) {
      if (session.expiresAt <= now) this.sessions.delete(sid);
    }
  }
}
