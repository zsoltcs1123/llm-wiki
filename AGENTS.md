# AGENTS.md

Development home for the LLM Wiki system.

## Lineage

Based on [Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## Documents

- [WIKI-DESIGN-PRINCIPLES.md](WIKI-DESIGN-PRINCIPLES.md): boundary, scope, and growth rules
- [WIKI-ROADMAP.md](WIKI-ROADMAP.md): system development priorities
- [skills/wiki/SKILL.md](skills/wiki/SKILL.md): operate layer (init, migrate, ingest, query, lint, discard)
- [\_scaffold/](_scaffold/): canonical wiki skeleton used by `/wiki init`

## Skills

Install into a host repo: `./skills/install.sh <target>`.

When operate semantics change, update `skills/wiki/` and bump `metadata.version` in `SKILL.md`. When layout changes, sync `_scaffold/` and `skills/wiki/references/scaffold/`.

## Layout or convention changes

1. Copy `_scaffold/` to `skills/wiki/references/scaffold/`. Set template `scaffold:` to the new skill version.
2. Update `skills/wiki/references/commands/init.md` when init steps change.
3. Add a playbook under `skills/wiki/references/migrations/` when hosts must migrate existing wikis.
4. Document the release in [WIKI-CHANGELOG.md](WIKI-CHANGELOG.md).
5. Update `tests/lib/wiki-migrate.sh` when tier A rules or semver steps change.

## Tests

After you change resolve rules, init, migrate, or scaffold layout, run:

```bash
make test
```

See [tests/README.md](tests/README.md).

## Commits

Lightweight [Conventional Commits](https://www.conventionalcommits.org/) for development in this repo. Wiki content commits in host repos use a separate convention (see below).

### Format

```
<type>(<scope>): <summary>
```

- Imperative mood, lowercase subject, no trailing period.
- Keep the subject under ~72 characters.
- One logical change per commit. No body.

### Types

| Type       | Use for                             |
| ---------- | ----------------------------------- |
| `feat`     | New capability or behavior          |
| `fix`      | Bug fix                             |
| `docs`     | Documentation only                  |
| `refactor` | Restructure without behavior change |
| `chore`    | Housekeeping, sync, version bumps   |

### Scopes

Optional. Prefer a scope when the change is clearly localized.

| Scope      | Path                                                       |
| ---------- | ---------------------------------------------------------- |
| `wiki`     | wiki system development                                    |
| `scaffold` | `_scaffold/` and synced `skills/wiki/references/scaffold/` |
| `skills`   | changes to skills                                          |

Omit scope for repo-wide or ambiguous changes.