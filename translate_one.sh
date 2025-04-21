#!/bin/bash
SRC_FILE="$1"
DEST_FILE="$2"
LANG="$3"

# 调用 OpenAI API 翻译注释与可见文字
translate() {
  local text="$1"
  local lang_code="$2"

  local payload=$(jq -n \
    --arg model "deepseek-chat" \
    --arg lang "$lang_code" \
    --arg text "$text" '
    {
      model: $model,
      messages: [
        {
          role: "system",
          content: "你是一个专业的翻译助手。请将用户提供的 Handlebars 模板文本翻译为\($lang)，并严格保留 Handlebars 模板语法不变。不要在输出中添加任何注释或说明，仅返回翻译后的模板内容。"
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5
    }')

  response=$(curl -s https://api.deepseek.com/chat/completions \
    -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$payload")

  echo "$response" | jq -r '.choices[0].message.content'
}

translate "$(cat "$SRC_FILE")" "$LANG" >"$DEST_FILE"
