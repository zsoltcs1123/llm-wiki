# LLM Wiki

Development home for a structured implementation of [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

Karpathy's gist describes the core idea: instead of re-deriving knowledge from raw sources on every query, an LLM incrementally builds and maintains a persistent markdown wiki. This repo extends that pattern with role-based pages, a discard workflow, commit conventions, and routed skill delivery.

## Operate vs Develop

| Layer | What | Where |
| --- | --- | --- |
| **Operate** | How to run a wiki (init, ingest, query, lint, discard) | `skills/wiki/` — install into host repos |
| **Develop** | System design, roadmap, scaffold | This repo |

Consumers install skills. They do not fork this repo to start a wiki. New wikis are created in place via `/wiki init`.

## Install Skills

```bash
./skills/install.sh .          # install into host repo's .agents/skills/
./skills/install.sh --global # optional: user-wide install
./skills/install.sh --list     # list installable skills
```

Skills included: `wiki`, `summarize`, `quick-summarize`.

Re-run after pulling updates to refresh installed copies.

## Commands

| Command | Purpose |
| --- | --- |
| `/wiki init` | Create wiki structure (in-repo or `--submodule`) |
| `/wiki ingest` | Process new `raw/` material into `wiki/` (full ingest for sources/notes; stub ingest for reference corpora) |
| `/wiki query` | Answer from the wiki |
| `/wiki lint` | Bounded health-check pass |
| `/wiki discard` | Classified removal workflow |

## Hosting Patterns

### In-repo (default)

Wiki is a directory in the host repo:

```bash
/wiki init --path wikis/my-topic --slug my-topic
```

### Submodule beside codebase

Wiki in a separate repo, mounted at `wiki/`:

```bash
/wiki init --path wiki --submodule git@github.com:you/my-service-wiki.git --slug my-service
```

### Standalone wiki repo

Whole repo is one wiki:

```bash
/wiki init
```

## Repo Layout

```
llm-wiki/
├── README.md
├── AGENTS.md
├── WIKI-DESIGN-PRINCIPLES.md
├── WIKI-ROADMAP.md
├── skills/           # wiki + summarize + quick-summarize + install.sh
└── _scaffold/        # canonical skeleton copied by wiki init
```

## Smoke Tests

```bash
./tests/smoke/run.sh
```

Validates wiki root detection, resolve-wiki priority, and init scaffold behavior. See [tests/smoke/README.md](tests/smoke/README.md).

## Development Docs

- [WIKI-DESIGN-PRINCIPLES.md](WIKI-DESIGN-PRINCIPLES.md) — boundary, scope, growth rules
- [WIKI-ROADMAP.md](WIKI-ROADMAP.md) — system development priorities
- [skills/wiki/SKILL.md](skills/wiki/SKILL.md) — operate layer source
