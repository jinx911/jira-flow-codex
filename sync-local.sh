#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/skills"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
CODEX_DEST="$CODEX_HOME_DIR/skills"
AGENTS_DEST="$HOME/.agents/skills"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info(){ echo -e "${GREEN}[INFO]${NC} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1"; }
err(){  echo -e "${RED}[ERROR]${NC} $1"; }

DEFAULT_SKILLS=(dev-flow init-dev-flow spec-author dev-loop review-test ship learn bugfix-flow git-ops)
EXTRA_SKILLS=(create-team delete-team)

SKILLS=("${DEFAULT_SKILLS[@]}")
SYNC_NATIVE=1

while [ $# -gt 0 ]; do
  case "$1" in
    --all) SKILLS+=("${EXTRA_SKILLS[@]}"); info "追加依赖 skill: ${EXTRA_SKILLS[*]}" ;;
    --codex-only) SYNC_NATIVE=0 ;;
    -h|--help)
      cat <<'EOF'
sync-local.sh — 把仓库里的 dev-flow 系列 skill 拷贝到本地 Codex 目录

用法:
  ./sync-local.sh
  ./sync-local.sh --all
  ./sync-local.sh --codex-only
EOF
      exit 0 ;;
    *) err "未知参数: $1"; exit 1 ;;
  esac
  shift
done

mkdir -p "$CODEX_DEST"
if [ "$SYNC_NATIVE" = 1 ]; then
  mkdir -p "$AGENTS_DEST"
fi

copy_skill() {
  local skill="$1"
  local dest="$2"
  [ -d "$SRC/$skill" ] || { warn "仓库无此 skill，跳过: $skill"; return; }
  rm -rf "$dest/$skill"
  cp -R "$SRC/$skill" "$dest/$skill"
  info "同步: $skill -> $dest"
}

for skill in "${SKILLS[@]}"; do
  copy_skill "$skill" "$CODEX_DEST"
  if [ "$SYNC_NATIVE" = 1 ]; then
    copy_skill "$skill" "$AGENTS_DEST"
  fi
done

echo ""
info "校验："
OK=1
for skill in "${SKILLS[@]}"; do
  if [ -f "$CODEX_DEST/$skill/SKILL.md" ]; then
    echo "  ✅ $skill/SKILL.md"
  else
    echo "  ❌ $skill/SKILL.md 缺失"; OK=0
  fi
done

echo ""
if [ "$OK" = 1 ]; then
  info "同步完成。开新会话后 /dev-flow、/bugfix-flow、/init-dev-flow 等即可生效。"
else
  err "部分 skill 校验失败，请检查上方输出。"
  exit 1
fi
