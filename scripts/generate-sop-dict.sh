#!/bin/bash
# 根据 sop.md 或 sop.en.md 生成同目录下的 sop_dict.json 或 sop_dict.en.json
# 用法: ./scripts/generate-sop-dict.sh <path/to/sop.md|sop.en.md>

set -e

SOP_FILE="$1"

if [ -z "$SOP_FILE" ]; then
    echo "用法: $0 <path/to/sop.md|sop.en.md>"
    exit 1
fi

if [ ! -f "$SOP_FILE" ]; then
    echo "❌ 文件不存在: $SOP_FILE"
    exit 1
fi

SOP_DIR="$(dirname "$SOP_FILE")"
BASENAME="$(basename "$SOP_FILE" | tr '[:upper:]' '[:lower:]')"

# sop.en.md → sop_dict.en.json，其余（sop.md / SOP.md）→ sop_dict.json
if [ "$BASENAME" = "sop.en.md" ]; then
    OUTPUT_FILE="$SOP_DIR/sop_dict.en.json"
else
    OUTPUT_FILE="$SOP_DIR/sop_dict.json"
fi

python3 - "$SOP_FILE" "$OUTPUT_FILE" << 'PYEOF'
import json
import re
import sys

sop_file = sys.argv[1]
output_file = sys.argv[2]

with open(sop_file, "r", encoding="utf-8") as f:
    content = f.read()

sections = re.split(r'\n?---\n', content)

sop_dict = {}
for section in sections:
    section = section.strip()
    if not section:
        continue
    m = re.match(r'### SOP_(\d+)[：:]', section)
    if m:
        key = f"SOP_{m.group(1)}"
        sop_dict[key] = section

with open(output_file, "w", encoding="utf-8") as f:
    json.dump(sop_dict, f, ensure_ascii=False, indent=2)

print(f"   ✓ 已生成: {output_file}（共 {len(sop_dict)} 个 SOP）")
PYEOF
