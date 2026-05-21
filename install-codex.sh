#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_DIR/skills"

info() { printf '[INFO] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }

mkdir -p "$SKILLS_DIR"

count=0
for skill_dir in "$SCRIPT_DIR"/skills/*; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  target="$SKILLS_DIR/$name"

  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    warn "Skipping existing non-symlink: $target"
    continue
  fi

  ln -s "$skill_dir" "$target"
  info "Linked Codex skill: $name"
  count=$((count + 1))
done

printf '\nJira-Flow Codex installed: %s skill(s) linked to %s\n' "$count" "$SKILLS_DIR"
printf 'Try: 使用 jira-flow 处理 OA-3650\n'
