#!/usr/bin/env bash
#
# Install the skills in this repo into a project's (or your global) .agents/skills/.
# Once installed there, harnesses that read .agents/skills/ natively (Cursor 2.4+,
# Codex, Copilot, Gemini, Cline, ...) pick them up with no further setup.
#
# Usage:
#   ./install.sh [TARGET]        Install into TARGET/.agents/skills/ (default: current dir)
#   ./install.sh --global        Install into ~/.agents/skills/
#   ./install.sh --check [TARGET] Compare installed vs source skill versions; exit 1 on drift
#   ./install.sh --pin <file> [TARGET]  compare installed skills to pin file
#   ./install.sh --list          List installable skills and exit
#
# Skills are copied as snapshots; re-run this script to update them.
#
# Pin file format (optional): one line per skill, "name version", e.g. "wiki 1.5"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

skill_version_from_skill_md() {
  local skill_md="$1"
  awk -F': *' '/^[[:space:]]*version:/ { gsub(/["'\'']/, "", $2); print $2; exit }' "$skill_md" | tr -d '\r' | xargs
}

pin_version_for_skill() {
  local pin_file="$1"
  local skill_name="$2"
  [[ -f "$pin_file" ]] || return 1
  awk -v name="$skill_name" '$1 == name { print $2; exit }' "$pin_file"
}

target=""
global=false
check=false
pin_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) global=true; shift ;;
    --check) check=true; shift ;;
    --pin)
      pin_file="${2:?--pin requires a file}"
      check=true
      shift 2
      ;;
    --list)
      echo "Installable skills:"
      for d in "$SCRIPT_DIR"/*/; do
        [ -f "${d}SKILL.md" ] && echo "  - $(basename "$d")"
      done
      exit 0
      ;;
    --*) echo "Unknown option: $1" >&2; exit 1 ;;
    *)
      target="$1"
      shift
      ;;
  esac
done

if $global; then
  dest="$HOME/.agents/skills"
else
  dest="${target:-$PWD}/.agents/skills"
fi

if $check; then
  drift=0
  for d in "$SCRIPT_DIR"/*/; do
    [ -f "${d}SKILL.md" ] || continue
    name="$(basename "$d")"
    src_ver="$(skill_version_from_skill_md "${d}SKILL.md")"
    installed="$dest/$name/SKILL.md"
    if [[ ! -f "$installed" ]]; then
      echo "  missing: $name (source $src_ver)" >&2
      drift=1
      continue
    fi
    inst_ver="$(skill_version_from_skill_md "$installed")"
    expected="$src_ver"
    if [[ -n "$pin_file" ]]; then
      if pinned="$(pin_version_for_skill "$pin_file" "$name")"; then
        expected="$pinned"
      fi
    fi
    if [[ "$inst_ver" != "$expected" ]]; then
      echo "  drift: $name installed=$inst_ver expected=$expected" >&2
      drift=1
    else
      echo "  ok: $name $inst_ver"
    fi
  done
  if [[ "$drift" -ne 0 ]]; then
    exit 1
  fi
  exit 0
fi

mkdir -p "$dest"

installed=0
for d in "$SCRIPT_DIR"/*/; do
  [ -f "${d}SKILL.md" ] || continue
  name="$(basename "$d")"
  link="$dest/$name"
  rm -rf "$link"
  cp -R "$d" "$link"
  echo "  copy: $name -> $link"
  installed=$((installed + 1))
done

echo "Installed $installed skill(s) into $dest"