#!/bin/bash
set -e

UPSTREAM_REPO="https://github.com/dani-garcia/vaultwarden.git"
TARGET_DIR="templates"
TMP_DIR=$(mktemp -d)
LANGS=("zh-cn" "zh-tw" "ja" "ko")

# 获取最新 tag
latest_tag=$(git ls-remote --tags --sort="v:refname" $UPSTREAM_REPO | grep -o 'refs/tags/.*' | grep -v '{}' | tail -n1 | sed 's#refs/tags/##')

echo "Latest tag: $latest_tag"

# 如果当前 tag 已存在，则退出
if git tag | grep -q "$latest_tag"; then
  echo "Tag $latest_tag already exists. Exiting."
  exit 0
fi

# Clone 并 checkout 最新 tag
git clone --depth 1 --branch "$latest_tag" "$UPSTREAM_REPO" "$TMP_DIR"

NEW_TEMPLATES_DIR="$TMP_DIR/src/static/templates"

# 对每种语言进行翻译
for lang in "${LANGS[@]}"; do
  OUT_DIR="templates.$lang"
  mkdir -p "$OUT_DIR"

  # 遍历所有 .hbs 文件
  find "$NEW_TEMPLATES_DIR" -type f -name "*.hbs" | while read -r new_file; do
    relative_path="${new_file#$NEW_TEMPLATES_DIR/}"
    old_file="$TARGET_DIR/$relative_path"
    translated_file="$OUT_DIR/$relative_path"

    # 如果旧文件存在且内容一致，则跳过翻译
    if [[ -f "$old_file" ]] && cmp -s "$new_file" "$old_file"; then
      echo "Unchanged: $relative_path, skipping translation for $lang"
      continue
    fi

    echo "Translating $relative_path to $lang..."
    mkdir -p "$(dirname "$translated_file")"
    bash ./translate_one.sh "$new_file" "$translated_file" "$lang"
  done
done

rm -rf "$TARGET_DIR"
cp -r "$NEW_TEMPLATES_DIR" "$TARGET_DIR"

# 提交变更
git add .
if [ -z "$(git diff --cached)" ]; then
  echo "No changes to commit."
else
  git commit -m "Update templates to $latest_tag"
  git tag "$latest_tag"
  git push origin main --tags
fi
