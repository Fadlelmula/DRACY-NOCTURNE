import { loadConfig } from "./config.ts";
import { createApp } from "./server.ts";

const config = loadConfig();
const server = createApp(config);

server.listen(config.port, config.host, () => {
  console.log(`DRACY backend listening on http://${config.host}:${config.port}`);
  console.log(`Optional AI provider: ${config.provider.enabled ? "configured" : "disabled (scripted fallback active)"}`);
  if (!process.env.SESSION_SECRET) {
    console.warn("SESSION_SECRET is not set; using an ephemeral development secret. Sessions will invalidate on restart.");
  }
});

for (const signal of ["SIGINT", "SIGTERM"] as const) {
  process.once(signal, () => {
    server.close(() => process.exit(0));
  });
}
