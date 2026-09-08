# AGENTS.md

Development home for the LLM Wiki system.

## Lineage

Based on [Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## Documents

- [WIKI-DESIGN-PRINCIPLES.md](WIKI-DESIGN-PRINCIPLES.md): boundary, scope, and growth rules
- [WIKI-ROADMAP.md](WIKI-ROADMAP.md): system development priorities
- [skills/wiki/SKILL.md](skills/wiki/SKILL.md): operate layer (ingest, query, lint, discard, init)
- [_scaffold/](_scaffold/): canonical wiki skeleton used by `/wiki init`

## Skills

Install into a host repo: `./skills/install.sh <target>`.

When changing operate semantics, update `skills/wiki/` and bump `metadata.version` in `SKILL.md`. Sync scaffold changes to both `_scaffold/` and `skills/wiki/references/scaffold/`.

## Scaffold Changes

If you change the wiki directory structure, update:

1. `_scaffold/`
2. `skills/wiki/references/scaffold/` (copy)
3. `skills/wiki/references/commands/init.md` if init steps change
