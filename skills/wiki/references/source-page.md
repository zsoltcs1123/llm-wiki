# Source page layout

One file per source: `wiki/sources/{author}/{slug}.md`. No `quick/` siblings.

## Section order

Below frontmatter, in this order only:

1. **Quick summary** — `quick-summarize` (drop duplicate `#` title when `summarize` supplies one)
2. **Full summary** — `summarize` (title, metadata, body)
3. **Citations** — `citations`, always last

Put `---` between quick and full blocks when both are present.

## Citations

```markdown
## Citations

- [bullet per citations skill]
```

Run on the same raw input as summarization; concrete references only. If none qualify:

```markdown
## Citations

No citations found.
```

Nothing may follow `## Citations`. Re-ingest replaces that section.

## Frontmatter

```yaml
type: source
status: draft | maintained
updated: YYYY-MM-DD
source_org: optional
tags: [optional]
```

Preserve frontmatter; bump `updated` on re-ingest.

## Re-ingest

Replace quick summary, full summary, and citations from raw. No stale blocks; no `quick/` pages.