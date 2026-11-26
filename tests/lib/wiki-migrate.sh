#!/usr/bin/env bash
#
# Bash mirror of tier A and mechanical migrate steps in skills/wiki/references/commands/migrate.md

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=skill-version.sh
source "$LIB_DIR/skill-version.sh"

# Ordered scaffold semver steps (extend when new playbooks ship).
WIKI_SCAFFOLD_STEPS=("1.0" "1.1" "1.2" "1.3")

wiki_scaffold_read() {
  local root="${1%/}"
  local yaml="$root/.wiki-root.yaml"

  if [[ ! -f "$yaml" ]]; then
    echo "1.0"
    return 0
  fi

  local scaffold
  scaffold="$(awk -F': *' '/^scaffold:/ { gsub(/["'\'']/, "", $2); print $2; exit }' "$yaml" | tr -d '\r' | xargs)"
  if [[ -n "$scaffold" ]]; then
    echo "$scaffold"
  else
    echo "1.0"
  fi
}

wiki_scaffold_write() {
  local root="${1%/}"
  local version="$2"
  local yaml="$root/.wiki-root.yaml"
  local slug name

  if [[ -f "$yaml" ]]; then
    slug="$(awk -F': *' '/^slug:/ { gsub(/["'\'']/, "", $2); print $2; exit }' "$yaml" | tr -d '\r' | xargs)"
    name="$(awk -F': *' '/^name:/ { gsub(/["'\'']/, "", $2); print $2; exit }' "$yaml" | tr -d '\r' | xargs)"
  fi
  slug="${slug:-$(basename "$root")}"
  name="${name:-$slug}"

  cat >"$yaml" <<EOF
slug: $slug
name: $name
scaffold: "$version"
EOF
}

wiki_migrate_target_version() {
  local repo_root="${1%/}"
  wiki_skill_version "$repo_root"
}

wiki_scaffold_index() {
  local ver="$1"
  local i
  for i in "${!WIKI_SCAFFOLD_STEPS[@]}"; do
    if [[ "${WIKI_SCAFFOLD_STEPS[$i]}" == "$ver" ]]; then
      echo "$i"
      return 0
    fi
  done
  return 1
}

wiki_migrate_playbook_chain() {
  local from="$1"
  local to="$2"
  local migrations_dir="${3%/}"

  local from_idx to_idx
  from_idx="$(wiki_scaffold_index "$from")" || return 1
  to_idx="$(wiki_scaffold_index "$to")" || return 1

  if [[ "$from_idx" -ge "$to_idx" ]]; then
    return 0
  fi

  local i from_ver to_ver playbook
  for ((i = from_idx; i < to_idx; i++)); do
    from_ver="${WIKI_SCAFFOLD_STEPS[$i]}"
    to_ver="${WIKI_SCAFFOLD_STEPS[$((i + 1))]}"
    playbook="$migrations_dir/${from_ver}-to-${to_ver}.md"
    if [[ ! -f "$playbook" ]]; then
      echo "wiki_migrate_playbook_chain: missing $playbook" >&2
      return 1
    fi
    echo "$(basename "$playbook")"
  done
}

wiki_migrate_path_denied_overwrite() {
  local relpath="${1#/}"

  case "$relpath" in
    wiki/index.md | wiki/log.md | README.md | HOME.md)
      return 0
      ;;
  esac

  case "$relpath" in
    wiki/sources/* | wiki/concepts/* | wiki/entities/* | wiki/syntheses/*)
      return 0
      ;;
    raw/sources/* | raw/notes/*)
      return 0
      ;;
  esac

  return 1
}

wiki_migrate_additive_sync() {
  local wiki_root="${1%/}"
  local scaffold_dir="${2%/}"
  local accept_overwrites="${3:-false}"

  if [[ ! -d "$scaffold_dir" ]]; then
    echo "wiki_migrate_additive_sync: missing scaffold $scaffold_dir" >&2
    return 1
  fi

  (
    cd "$scaffold_dir"
    find . -mindepth 1 \( -type f -o -type d \) | sort
  ) | while IFS= read -r rel; do
    rel="${rel#./}"
    local src="$scaffold_dir/$rel"
    local dest="$wiki_root/$rel"

    if [[ -d "$src" ]]; then
      if [[ ! -d "$dest" ]]; then
        mkdir -p "$dest"
      fi
      continue
    fi

    if [[ -f "$dest" ]]; then
      if wiki_migrate_path_denied_overwrite "$rel"; then
        continue
      fi
      if [[ "$accept_overwrites" == "true" ]]; then
        cp "$src" "$dest"
      fi
      continue
    fi

    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
  done
}

wiki_migrate_list_additive_missing() {
  local wiki_root="${1%/}"
  local scaffold_dir="${2%/}"

  (
    cd "$scaffold_dir"
    find . -type f | sort
  ) | while IFS= read -r rel; do
    rel="${rel#./}"
    local dest="$wiki_root/$rel"
    if [[ ! -f "$dest" ]]; then
      echo "$rel"
    fi
  done
}

wiki_migrate_ensure_wiki_root_yaml() {
  local root="${1%/}"
  local yaml="$root/.wiki-root.yaml"
  if [[ ! -f "$yaml" ]]; then
    cat >"$yaml" <<EOF
slug: $(basename "$root")
name: $(basename "$root")
EOF
  fi
}

wiki_index_apply_hub_policy() {
  local index="$1"
  if [[ ! -f "$index" ]]; then
  echo "wiki_index_apply_hub_policy: missing $index" >&2
    return 1
  fi

  local tmp
  tmp="$(mktemp)"
  awk '
    BEGIN { skip = 0; has_concepts = 0; has_entities = 0; has_synth = 0; has_ref = 0 }
    /^## Sources(\s|$)/ { skip = 1; next }
    /^## / {
      if (skip) { skip = 0 }
      if ($0 ~ /^## Concepts/) { has_concepts = 1 }
      if ($0 ~ /^## Entities/) { has_entities = 1 }
      if ($0 ~ /^## Syntheses/) { has_synth = 1 }
      if ($0 ~ /^## Reference/) { has_ref = 1 }
    }
    !skip { print }
    END {
      if (!has_concepts) {
        print ""
        print "## Concepts"
        print ""
        print "_No concept pages yet._"
      }
      if (!has_entities) {
        print ""
        print "## Entities"
        print ""
        print "_No entity pages yet._"
      }
      if (!has_synth) {
        print ""
        print "## Syntheses"
        print ""
        print "_No synthesis pages yet._"
      }
      if (!has_ref) {
        print ""
        print "## Reference Corpora"
        print ""
        print "_No reference corpora yet._"
      }
    }
  ' "$index" >"$tmp"
  mv "$tmp" "$index"
}

wiki_migrate_mechanical_playbook() {
  local wiki_root="${1%/}"
  local playbook_basename="$2"
  local scaffold_dir="${3%/}"

  case "$playbook_basename" in
    1.0-to-1.1.md)
      wiki_migrate_ensure_wiki_root_yaml "$wiki_root"
      wiki_scaffold_write "$wiki_root" "1.1"
      ;;
    1.1-to-1.2.md)
      wiki_index_apply_hub_policy "$wiki_root/wiki/index.md"
      wiki_scaffold_write "$wiki_root" "1.2"
      ;;
    1.2-to-1.3.md)
      wiki_migrate_additive_sync "$wiki_root" "$scaffold_dir" false
      wiki_scaffold_write "$wiki_root" "1.3"
      ;;
    *)
      echo "wiki_migrate_mechanical_playbook: unknown $playbook_basename" >&2
      return 1
      ;;
  esac
}

wiki_migrate_mechanical_apply() {
  local wiki_root="${1%/}"
  local repo_root="${2%/}"
  local migrations_dir="${3%/}"
  local scaffold_dir="${4%/}"
  local target
  target="$(wiki_migrate_target_version "$repo_root")"

  local current="$(
    wiki_scaffold_read "$wiki_root"
  )"
  local playbook
  while IFS= read -r playbook; do
    [[ -n "$playbook" ]] || continue
    wiki_migrate_mechanical_playbook "$wiki_root" "$playbook" "$scaffold_dir"
    current="$(wiki_scaffold_read "$wiki_root")"
  done < <(wiki_migrate_playbook_chain "$current" "$target" "$migrations_dir")

  wiki_scaffold_write "$wiki_root" "$target"
}

wiki_migrate_plan_playbook_names() {
  local from="$1"
  local to="$2"
  local migrations_dir="${3%/}"
  wiki_migrate_playbook_chain "$from" "$to" "$migrations_dir" | paste -sd, -
}