#!/usr/bin/env node

/**
 * Lightweight translator that calls OpenRouter via @openrouter/sdk.
 * Stdout: translated text only; Stderr: diagnostics.
 */

import process from "node:process";

const readStdin = async () =>
  new Promise((resolve, reject) => {
    let data = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => {
      data += chunk;
    });
    process.stdin.on("end", () => resolve(data));
    process.stdin.on("error", reject);
  });

let OpenRouterCtor;
try {
  const mod = await import("@openrouter/sdk");
  OpenRouterCtor = mod.default ?? mod.OpenRouter;
  if (!OpenRouterCtor) {
    throw new Error("OpenRouter constructor not found in @openrouter/sdk");
  }
} catch (error) {
  const hint =
    error?.code === "ERR_MODULE_NOT_FOUND"
      ? "依赖缺失：请在仓库根目录运行 `npm install` 安装 @openrouter/sdk。"
      : "";
  console.error(`❌ 无法加载 @openrouter/sdk：${error?.message ?? error}`);
  if (hint) {
    console.error(hint);
  }
  process.exit(1);
}

const apiKey = process.env.OPENROUTER_API_KEY;
if (!apiKey) {
  console.error("❌ OPENROUTER_API_KEY 未设置");
  process.exit(1);
}

const baseURL = process.env.OPENROUTER_BASE_URL || "https://openrouter.ai/api/v1";
const model =
  process.env.MODEL ||
  process.env.OPENROUTER_MODEL ||
  "anthropic/claude-opus-4.6";
const maxTokens = Number(
  process.env.MAX_TOKENS || process.env.OPENROUTER_MAX_TOKENS || 8000
);
const systemPrompt = process.env.TRANSLATION_SYSTEM_PROMPT || "";
const content = (await readStdin()) || "";

if (!content.trim()) {
  console.error("❌ 未收到待翻译内容（stdin 为空）");
  process.exit(1);
}

let client;
try {
  client = new OpenRouterCtor({ apiKey, baseURL });
} catch (error) {
  console.error(`❌ 创建 OpenRouter 客户端失败: ${error?.message ?? error}`);
  process.exit(1);
}

const messages = [];
if (systemPrompt.trim()) {
  messages.push({ role: "system", content: systemPrompt });
}
messages.push({
  role: "user",
  content: `请将以下中文提示词翻译为英文：\n\n${content}`,
});

let response;
try {
  response = await client.chat.send({
    chatGenerationParams: {
      model,
      messages,
      maxTokens,
      temperature: 0,
    },
  });
} catch (error) {
  console.error(`❌ OpenRouter 请求失败: ${error?.message ?? error}`);
  process.exit(1);
}

const choice = response?.choices?.[0];
const messageContent = choice?.message?.content;

let text = "";
if (Array.isArray(messageContent)) {
  text = messageContent
    .map((part) =>
      typeof part === "string" ? part : part?.text ? String(part.text) : ""
    )
    .join("");
} else if (typeof messageContent === "string") {
  text = messageContent;
} else if (messageContent && typeof messageContent?.text === "string") {
  text = messageContent.text;
}

if (!text.trim()) {
  console.error("❌ 未能从响应中解析到翻译结果");
  process.exit(1);
}

process.stdout.write(text);
