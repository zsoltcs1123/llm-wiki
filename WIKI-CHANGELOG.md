# Wiki skill changelog

Consumer-facing operate layer notes. This file lives in the dev repo only. Init does not copy it into wikis.

## 1.3

- `/wiki migrate` supports dry-run (default), `--apply`, and `--to`. Tier A adds missing scaffold files. Tier B runs versioned playbooks.
- `.wiki-root.yaml` `scaffold` records the last completed layout migration. If the key is missing, the wiki is version `1.0`.
- To upgrade from skill 1.2 or older: run `install.sh`, then `/wiki migrate` on each wiki. Playbooks may include `1.0-to-1.1`, `1.1-to-1.2`, and `1.2-to-1.3`.
- Optional: `skills/install.sh --check` compares installed skill copies to the source tree.

## 1.2

- `wiki/index.md` lists only concepts, entities, syntheses, and reference corpora.
- Large corpora use `raw/reference/` with stub ingest.

## 1.1

- Run migrate on legacy wikis to backfill `.wiki-root.yaml` `slug` when you upgrade past 1.0.