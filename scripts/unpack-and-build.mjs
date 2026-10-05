#!/usr/bin/env node
import { readdirSync, readFileSync, writeFileSync, existsSync } from "node:fs";
import { execSync } from "node:child_process";
import { join } from "node:path";
const dir = "deploy-chunks";
const parts = readdirSync(dir).filter((f) => f.endsWith(".b64")).sort();
const b64 = parts.map((f) => readFileSync(join(dir, f), "utf8")).join("");
writeFileSync("src.tgz", Buffer.from(b64, "base64"));
execSync("tar xzf src.tgz", { stdio: "inherit" });
execSync("npm install", { stdio: "inherit" });
execSync("node scripts/with-app-env.mjs vite build && npm run db:migrate", {
  stdio: "inherit",
  env: process.env,
});
