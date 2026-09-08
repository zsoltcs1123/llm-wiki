# Wiki Query

When answering research questions against a wiki:

1. Start from `wiki/index.md`.
2. Read the relevant wiki pages first.
3. Read `raw/` only when the wiki is insufficient or provenance needs checking.
4. By default, answer in chat only.
5. Only write to `wiki/syntheses/` if the user explicitly asks for a durable synthesis artifact.
6. Update `wiki/index.md` and `wiki/log.md` only if a wiki page was actually created or changed.
7. Commit the changes if files changed, using the standardized wiki commit format and the operation that best matches the work per [commits.md](../commits.md).

## Before Starting

- Resolve target wiki per [resolve-wiki.md](../resolve-wiki.md).
- Read [model.md](../model.md) for structure and writing style when creating pages.

## Default Route

When `/wiki` is invoked with a question and no explicit command, treat it as query.
