# Smoke Tests

Executable checks for wiki operate semantics. Run after changing resolve rules, init, or scaffold layout.

```bash
./tests/smoke/run.sh
```

## Layout

| Path | Purpose |
| --- | --- |
| `run.sh` | Test runner |
| `lib/resolve-wiki.sh` | Bash mirror of `skills/wiki/references/resolve-wiki.md` |
| `lib/wiki-init.sh` | Minimal init helper for init smoke case |
| `fixtures/multi-wiki-host/` | Three wikis (`alpha`, `beta`, `gamma-no-yaml`) + registry |
| `fixtures/single-wiki-root/` | Standalone wiki-at-repo-root host |

## What it covers

- wiki root detection (`wiki/index.md` + `raw/{sources,notes,reference}/`)
- resolution priority: `--path`, `--wiki`, cwd walk-up, named registry slug, repo scan
- ambiguous multi-wiki scan (exit 2)
- slug from `.wiki-root.yaml` and directory-name fallback
- init scaffold copy, `.wiki-root.yaml` write, registry append

## Sync rule

When `skills/wiki/references/resolve-wiki.md` changes, update `lib/resolve-wiki.sh` and extend `run.sh`.
