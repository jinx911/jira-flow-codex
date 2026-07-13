#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_DIR/skills"
AGENTS_SKILLS_DIR="$HOME/.agents/skills"
COMMANDS_DIR="$CODEX_DIR/commands"
WORKFLOWS_DIR="$CODEX_DIR/workflows"

info() { printf '[INFO] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }

removed_skills=0
removed_native=0
removed_commands=0

for skill_dir in "$SCRIPT_DIR"/skills/*; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"

  skill_target="$SKILLS_DIR/$name"
  native_target="$AGENTS_SKILLS_DIR/$name"

  if [ -L "$skill_target" ]; then
    rm "$skill_target"
    info "Removed Codex skill symlink: $name"
    removed_skills=$((removed_skills + 1))
  elif [ -e "$skill_target" ]; then
    warn "Skipping non-symlink skill target: $skill_target"
  fi

  if [ -L "$native_target" ]; then
    rm "$native_target"
    info "Removed native skill symlink: $name"
    removed_native=$((removed_native + 1))
  elif [ -e "$native_target" ]; then
    warn "Skipping non-symlink native target: $native_target"
  fi
done

for command_file in "$SCRIPT_DIR"/commands/*.md; do
  [ -f "$command_file" ] || continue
  name="$(basename "$command_file")"
  command_target="$COMMANDS_DIR/$name"
  workflow_target="$WORKFLOWS_DIR/$name"

  rm -f "$command_target" "$workflow_target"
  info "Removed command/workflow shim: ${name%.md}"
  removed_commands=$((removed_commands + 1))
done

printf '\nRemoved Codex skills: %s\n' "$removed_skills"
printf 'Removed native skills: %s\n' "$removed_native"
printf 'Removed command shims: %s\n' "$removed_commands"
