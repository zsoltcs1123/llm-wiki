#!/usr/bin/env bash
#
# Minimal init helper for smoke tests. Mirrors skills/wiki/references/commands/init.md.

set -euo pipefail

# shellcheck source=resolve-wiki.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resolve-wiki.sh"

wiki_init() {
  local target="${1%/}"
  local slug="$2"
  local scaffold_dir="${3%/}"
  local repo_root="${4%/}"
  local registry_rel="${5:-wikis/AGENTS.md}"

  if wiki_is_root "$target"; then
    echo "wiki init: target already looks like a wiki root: $target" >&2
    return 1
  fi

  mkdir -p "$target"
  cp -R "$scaffold_dir/." "$target/"

  cat >"$target/.wiki-root.yaml" <<EOF
slug: $slug
name: $slug
EOF

  local host_registry="$repo_root/$registry_rel"
  mkdir -p "$(dirname "$host_registry")"

  if [[ ! -f "$host_registry" ]]; then
    cat >"$host_registry" <<'EOF'
# Wikis

| Slug | Path | Notes |
| --- | --- | --- |
EOF
  fi

  local rel_path="${target#"$repo_root"/}"
  printf '| %s | %s/ | Smoke test wiki |\n' "$slug" "$rel_path" >>"$host_registry"
}
