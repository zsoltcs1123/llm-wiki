---
name: wiki
description: >-
  Operate an LLM-maintained markdown wiki — init structure, ingest raw sources,
  query the knowledge base, lint for gaps, discard pages. Use when the user says
  /wiki, wiki init, wiki ingest, wiki query, wiki lint, wiki discard, lint pass,
  ingest into wiki, or asks research questions against a wiki.
metadata:
  author: zs
  version: "1.0"
---

# Wiki

## Outcome

Operate a focused LLM-maintained wiki: scaffold structure, ingest raw material into maintained pages, answer from the wiki, run bounded lint passes, discard content through a classified workflow.

Based on [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## Route

| Command          | Load                                                                                                                 |
| ---------------- | -------------------------------------------------------------------------------------------------------------------- |
| (none / unclear) | [commands/query.md](references/commands/query.md) if a question is present; otherwise list commands and resolve wiki |
| `init`           | [commands/init.md](references/commands/init.md)                                                                      |
| `ingest`         | [commands/ingest.md](references/commands/ingest.md)                                                                  |
| `query`          | [commands/query.md](references/commands/query.md)                                                                    |
| `lint`           | [commands/lint.md](references/commands/lint.md)                                                                      |
| `discard`        | [commands/discard.md](references/commands/discard.md)                                                                |

1. First word is `init`, `ingest`, `query`, `lint`, or `discard` → load that reference. Remainder is the target or argument.
2. Intent clearly maps (e.g. "ingest this source", "lint pass", "remove this page") → load the matching reference.
3. Bare `/wiki` or unclear → resolve wiki per [resolve-wiki.md](references/resolve-wiki.md), list commands, ask if needed.

Before any mutating command (`init`, `ingest`, `lint`, `discard`), resolve the target wiki per [resolve-wiki.md](references/resolve-wiki.md).

Read [model.md](references/model.md) for repo structure, page roles, frontmatter, writing style, and working rules. Read [commits.md](references/commits.md) before creating wiki git commits.

## Guardrails

- Treat `wiki/` as the maintained artifact; do not edit `raw/` during normal maintenance.
- Do not create or update `wiki/syntheses/` unless the user explicitly asks for synthesis work.
- Deletion is a wiki operation. Use the discard workflow; do not delete files and rely on a later lint pass.
- Do not promote a note into `wiki/sources/` unless provenance is preserved in `raw/notes/` or verbatim in `raw/sources/`.
- During ingest, surface contradictions, stale claims, overlap, and structural issues instead of silently merging them away.
- For `concept` pages, do not generate an `Implications for This Repo` section.
- Commit once per completed wiki-changing workflow when files changed. No commit for no-op runs.
- During ingest, use the `summarize` and `quick-summarize` skills for source and quick pages if present.
