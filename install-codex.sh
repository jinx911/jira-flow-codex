#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_DIR/skills"
COMMANDS_DIR="$CODEX_DIR/commands"
WORKFLOWS_DIR="$CODEX_DIR/workflows"

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

if [ -d "$SCRIPT_DIR/commands" ]; then
  mkdir -p "$COMMANDS_DIR" "$WORKFLOWS_DIR"
  for command_file in "$SCRIPT_DIR"/commands/*.md; do
    [ -f "$command_file" ] || continue
    name="$(basename "$command_file")"

    command_target="$COMMANDS_DIR/$name"
    workflow_target="$WORKFLOWS_DIR/$name"

    if [ -L "$command_target" ]; then
      rm "$command_target"
    elif [ -e "$command_target" ]; then
      warn "Skipping existing non-symlink command: $command_target"
      command_target=""
    fi

    if [ -n "$command_target" ]; then
      ln -s "$command_file" "$command_target"
      info "Linked command shim: ${name%.md}"
    fi

    if [ -L "$workflow_target" ]; then
      rm "$workflow_target"
    elif [ -e "$workflow_target" ]; then
      warn "Skipping existing non-symlink workflow: $workflow_target"
      workflow_target=""
    fi

    if [ -n "$workflow_target" ]; then
      ln -s "$command_file" "$workflow_target"
      info "Linked workflow shim: ${name%.md}"
    fi
  done
fi

printf 'Try: /jira-flow PROJ-123\n'
printf 'Fallback: 使用 jira-flow 处理 PROJ-123\n'
