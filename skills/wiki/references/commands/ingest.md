# Wiki Ingest

When new material is added to `raw/`:

1. Read the new file(s) in `raw/`.
2. Create or update a corresponding page in `wiki/sources/{author}/` and, when applicable, a quick summary in `wiki/sources/{author}/quick/`. Use the author-folder naming rule from [model.md](../model.md). Use the `summarize` and `quick-summarize` skills.
3. Identify contradictions, stale claims, overlap, or structural issues the new source exposes in existing `wiki/sources/`, `wiki/concepts/`, and `wiki/entities/`.
4. Update affected maintained pages to reflect disagreement, uncertainty, supersession, duplication, or unresolved tension when the new source changes the current understanding.
5. Update `wiki/syntheses/` only if the user explicitly asks for synthesis work and the new source materially changes an existing synthesis.
6. Update `wiki/index.md`.
7. Append an ingest entry to `wiki/log.md`, noting contradiction or issue handling when it occurred.
8. Commit the changes if files changed, using `wiki(<wiki-slug>) ingest: <summary>` per [commits.md](../commits.md).

One source may update many wiki pages. That is expected.

## Before Starting

- Resolve target wiki per [resolve-wiki.md](../resolve-wiki.md).
- Read [model.md](../model.md) for structure, roles, and working rules.
