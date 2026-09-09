#!/usr/bin/env bash

set -euo pipefail

SMOKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SMOKE_DIR/../.." && pwd)"

# shellcheck source=lib/assert.sh
source "$SMOKE_DIR/lib/assert.sh"
# shellcheck source=lib/resolve-wiki.sh
source "$SMOKE_DIR/lib/resolve-wiki.sh"
# shellcheck source=lib/wiki-init.sh
source "$SMOKE_DIR/lib/wiki-init.sh"

MULTI_HOST="$SMOKE_DIR/fixtures/multi-wiki-host"
SINGLE_HOST="$SMOKE_DIR/fixtures/single-wiki-root"
SCAFFOLD_DIR="$REPO_ROOT/skills/wiki/references/scaffold"

resolve_capture() {
  local exit_code=0
  local output=""

  set +e
  output="$(wiki_resolve "$@")"
  exit_code=$?
  set -e

  printf '%s' "$output"
  return "$exit_code"
}

resolve_exit_code() {
  set +e
  wiki_resolve "$@" >/dev/null
  local exit_code=$?
  set -e
  echo "$exit_code"
}

echo "resolve-wiki smoke tests"
echo

echo "fixtures"
assert_eq "multi host alpha is wiki root" "true" "$(wiki_is_root "$MULTI_HOST/wikis/alpha" && echo true || echo false)"
assert_eq "multi host repo root is not wiki root" "false" "$(wiki_is_root "$MULTI_HOST" && echo true || echo false)"
assert_eq "single host repo root is wiki root" "true" "$(wiki_is_root "$SINGLE_HOST" && echo true || echo false)"

echo
echo "slug"
assert_eq "slug from .wiki-root.yaml" "alpha" "$(wiki_slug_from_root "$MULTI_HOST/wikis/alpha")"
assert_eq "slug fallback to directory name" "gamma-no-yaml" "$(wiki_slug_from_root "$MULTI_HOST/wikis/gamma-no-yaml")"

echo
echo "explicit --path"
assert_eq "resolve --path alpha" "$MULTI_HOST/wikis/alpha" "$(resolve_capture "$MULTI_HOST" "$MULTI_HOST" "wikis/alpha" "" "")"
assert_eq "resolve --path beta (absolute)" "$MULTI_HOST/wikis/beta" "$(resolve_capture "$MULTI_HOST" "$MULTI_HOST" "$MULTI_HOST/wikis/beta" "" "")"

echo
echo "explicit --wiki"
assert_eq "resolve --wiki alpha" "$MULTI_HOST/wikis/alpha" "$(resolve_capture "$MULTI_HOST" "$MULTI_HOST" "" "alpha" "")"
assert_eq "resolve --wiki beta via registry" "$MULTI_HOST/wikis/beta" "$(resolve_capture "$MULTI_HOST" "$MULTI_HOST" "" "beta" "")"
assert_eq "resolve --wiki missing" "1" "$(resolve_exit_code "$MULTI_HOST" "$MULTI_HOST" "" "missing" "")"
assert_eq "resolve --wiki gamma via dir slug" "$MULTI_HOST/wikis/gamma-no-yaml" "$(resolve_capture "$MULTI_HOST" "$MULTI_HOST" "" "gamma-no-yaml" "")"

echo
echo "cwd walk-up"
assert_eq "resolve from nested wiki dir" "$MULTI_HOST/wikis/alpha" "$(resolve_capture "$MULTI_HOST" "$MULTI_HOST/wikis/alpha/wiki/concepts" "" "" "")"

echo
echo "registry named wiki"
assert_eq "resolve named beta" "$MULTI_HOST/wikis/beta" "$(resolve_capture "$MULTI_HOST" "$MULTI_HOST" "" "" "beta")"

echo
echo "repo scan"
assert_eq "single wiki host auto-resolves" "$SINGLE_HOST" "$(resolve_capture "$SINGLE_HOST" "$SINGLE_HOST" "" "" "")"
assert_eq "multi wiki host scan is ambiguous" "2" "$(resolve_exit_code "$MULTI_HOST" "$MULTI_HOST" "" "" "")"
assert_eq "multi wiki host scan finds three roots" "3" "$(wiki_collect_roots "$MULTI_HOST" | wc -l | xargs)"

echo
echo "init"
INIT_TMP="$(mktemp -d)"
trap 'rm -rf "$INIT_TMP"' EXIT

wiki_init "$INIT_TMP/wikis/delta" "delta" "$SCAFFOLD_DIR" "$INIT_TMP"
assert_eq "init creates wiki root" "true" "$(wiki_is_root "$INIT_TMP/wikis/delta" && echo true || echo false)"
assert_eq "init writes slug" "delta" "$(wiki_slug_from_root "$INIT_TMP/wikis/delta")"
assert_eq "init appends registry row" "true" "$(grep -q '| delta | wikis/delta/ |' "$INIT_TMP/wikis/AGENTS.md" && echo true || echo false)"
assert_eq "init wiki resolves by slug" "$INIT_TMP/wikis/delta" "$(resolve_capture "$INIT_TMP" "$INIT_TMP" "" "delta" "")"

smoke_summary
