# LLM Wiki (archived)

**Development moved to [zsoltcs1123/ai-dev-zs](https://github.com/zsoltcs1123/ai-dev-zs)** → [`bundles/llm-wiki/`](https://github.com/zsoltcs1123/ai-dev-zs/tree/main/bundles/llm-wiki).

This repository is archived. Operate layer, tests, and system docs live in the bundle; standalone `citations` (and shared `summarize` / `quick-summarize`) live under `skills/` in that repo.

## Install (current)

```bash
git clone https://github.com/zsoltcs1123/ai-dev-zs.git
cd ai-dev-zs
./skills/install.sh <host-repo> --bundle llm-wiki
./skills/install.sh --skill citations <host-repo>   # citations only
```

Re-run install after pulling `ai-dev-zs` to refresh skills.

## Background

Structured implementation of [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f): persistent markdown wiki, ingest/query/lint/discard workflows, routed skill delivery. See bundle docs for design principles, roadmap, and changelog.