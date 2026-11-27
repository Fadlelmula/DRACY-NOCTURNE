interface Bucket {
  tokens: number;
  updatedAt: number;
}

export class RateLimiter {
  private readonly buckets = new Map<string, Bucket>();
  private readonly capacity: number;
  private readonly refillPerSecond: number;
  private readonly maxKeys: number;

  constructor(capacity: number, refillPerSecond: number, maxKeys: number = 10_000) {
    this.capacity = capacity;
    this.refillPerSecond = refillPerSecond;
    this.maxKeys = maxKeys;
  }

  check(key: string, now = Date.now()): { allowed: boolean; retryAfter: number } {
    this.cleanup(now);
    let bucket = this.buckets.get(key);
    if (!bucket) {
      bucket = { tokens: this.capacity, updatedAt: now };
      this.buckets.set(key, bucket);
    }
    const elapsed = Math.max(0, now - bucket.updatedAt) / 1000;
    bucket.tokens = Math.min(this.capacity, bucket.tokens + elapsed * this.refillPerSecond);
    bucket.updatedAt = now;
    if (bucket.tokens >= 1) {
      bucket.tokens -= 1;
      return { allowed: true, retryAfter: 0 };
    }
    return { allowed: false, retryAfter: Math.max(1, Math.ceil((1 - bucket.tokens) / this.refillPerSecond)) };
  }

  private cleanup(now: number): void {
    if (this.buckets.size < this.maxKeys) return;
    for (const [key, bucket] of this.buckets) {
      if (now - bucket.updatedAt > 60_000) this.buckets.delete(key);
    }
    if (this.buckets.size >= this.maxKeys) this.buckets.clear();
  }
}
