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

preflight() {
  info "Running preflight checks"

  if [ ! -d "$CODEX_DIR" ]; then
    warn "Codex home not found: $CODEX_DIR"
    warn "Run Codex once before relying on automatic discovery."
  fi

  if [ -d "$CODEX_DIR/skills" ]; then
    info "Codex skills directory found: $CODEX_DIR/skills"
  else
    warn "Codex skills directory not found; it will be created."
  fi

  if [ -d "$AGENTS_SKILLS_DIR" ]; then
    info "Native skills directory found: $AGENTS_SKILLS_DIR"
  else
    warn "Native skills directory not found: $AGENTS_SKILLS_DIR; it will be created."
  fi

  if [ -d "$CODEX_DIR/superpowers/skills" ] || [ -d "$CODEX_DIR/skills/superpowers" ] || [ -d "$AGENTS_SKILLS_DIR/superpowers" ]; then
    info "Superpowers skills detected"
  else
    warn "Superpowers skills not detected. Jira-Flow can install, but phase methodology annotations may be less effective."
  fi

  if [ -d "$CODEX_DIR/plugins/cache/openai-curated/atlassian-rovo" ] || [ -d "$CODEX_DIR/plugins/cache/openai-curated" ]; then
    info "Codex plugin cache found; verify Atlassian Rovo is enabled before running /jira-flow"
  else
    warn "Codex plugin cache not found. Atlassian Rovo may be unavailable until configured."
  fi

  if [ -d "$CODEX_DIR/commands" ] || [ -d "$CODEX_DIR/workflows" ]; then
    info "Command/workflow directory detected"
  else
    warn "Command/workflow directories not found; they will be created as compatibility shims."
  fi
}

preflight

mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_SKILLS_DIR"

count=0
native_count=0
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

  native_target="$AGENTS_SKILLS_DIR/$name"
  if [ -L "$native_target" ]; then
    rm "$native_target"
  elif [ -e "$native_target" ]; then
    warn "Skipping existing non-symlink native skill: $native_target"
    continue
  fi

  ln -s "$skill_dir" "$native_target"
  info "Linked native skill: $name"
  native_count=$((native_count + 1))
done

printf '\nJira-Flow Codex installed: %s skill(s) linked to %s\n' "$count" "$SKILLS_DIR"
printf 'Native discovery: %s skill(s) linked to %s\n' "$native_count" "$AGENTS_SKILLS_DIR"

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
      cp "$command_file" "$command_target"
      info "Installed command shim: ${name%.md}"
    fi

    if [ -L "$workflow_target" ]; then
      rm "$workflow_target"
    elif [ -e "$workflow_target" ]; then
      warn "Skipping existing non-symlink workflow: $workflow_target"
      workflow_target=""
    fi

    if [ -n "$workflow_target" ]; then
      cp "$command_file" "$workflow_target"
      info "Installed workflow shim: ${name%.md}"
    fi
  done
fi

printf 'Try: /jira-flow PROJ-123\n'
printf 'Fallback: 使用 jira-flow 处理 PROJ-123\n'
