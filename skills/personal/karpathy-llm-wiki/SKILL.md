---
name: karpathy-llm-wiki
description: "Use when building or maintaining a personal LLM-powered knowledge base. Triggers: ingesting sources into a wiki, querying wiki knowledge, linting wiki quality, 'add to wiki', 'what do I know about', or any mention of 'LLM wiki' or 'Karpathy wiki'."
---

# Karpathy LLM Wiki — Adattato per klens-knowledge

Build and maintain the KLens knowledge base. The wiki lives at `klens-knowledge/` — no `raw/` directory needed. Content is compiled directly into topic folders with numbered prefixes.

Core ideas from Karpathy:
- "The LLM writes and maintains the wiki; the human reads and asks questions."
- "The wiki is a persistent, compounding artifact."

## Architecture

The wiki root is `/home/gmasiero/projects/klens-knowledge/`. Structure:

```
klens-knowledge/
├── 00-index.md               ← Global index (auto-maintained)
├── log.md                    ← Append-only operation log (created by this skill)
├── 01-platform/
│   ├── overview.md
│   ├── architecture.md
│   ...
├── 02-cli/
│   ...
├── 08-microservices/
│   ...
└── 11-reference/
    ...
```

Rules:
- Topic folders use two-digit numeric prefix + name (`01-platform/`, `08-microservices/`).
- Each folder contains one or more `.md` articles.
- No `raw/` directory — all content is wiki content directly.
- `00-index.md` is the global index (one row per article, grouped by topic, with link + summary).
- `log.md` is the append-only operation log (created by this skill if missing).

### Initialization

Check if `klens-knowledge/` exists. If not, create it with `00-index.md` (heading `# KLens Knowledge Base Index`, empty body) and `log.md` (heading `# Wiki Log`, empty body).

If `klens-knowledge/` already exists but has no `log.md`, create it.

---

## Ingest

Add new knowledge directly into the wiki. No raw/ fetch step — content comes from user input, API calls, CLI commands, or web research.

### Steps

1. Determine which topic folder the content belongs to. Check existing folders first. Content about an existing topic → use that folder. New topic → create a new folder with the next logical numeric prefix.

2. Determine file placement:
   - **Same core subject as existing file** → Merge into that file. Update affected sections and add a `Sources` section if the info comes from an external source.
   - **New subject within existing topic** → Create a new `.md` file in that topic folder. Name it descriptively in kebab-case (e.g., `deployment-strategy.md`).
   - **New topic** → Create a new numbered folder (e.g., `12-new-topic/`) and add the first article.

3. Each article should have:
   - `##` heading for the article title
   - `###` subheadings for sections
   - Code blocks for commands, configs, API responses
   - Cross-links to other articles using relative paths: `[text](../02-cli/authentication.md)`
   - A `Sources` section at the bottom when content comes from external references

4. Wrap content in consistent formatting matching existing files (same heading style, code block style, table style).

### Cascade Updates

After adding content, check for ripple effects:
1. Scan articles in the same topic folder that might need cross-references to the new content.
2. Scan `00-index.md` and update entries for every touched article.

### Post-Ingest

Update `00-index.md`:
- Add or update entries for every touched article.
- Format: `| [filename](relative/path) | Brief summary |`

Append to `log.md`:
```
## [YYYY-MM-DD] ingest | <article title>
- Updated: <cascade-updated article title>
```

Omit `- Updated:` when no cascade updates occur.

---

## Query

Search the wiki and answer questions. Examples:
- "What do I know about the MCP service?"
- "Summarize everything about authentication"
- "How does the storage-service work?"

### Steps

1. Read `00-index.md` to locate relevant articles.
2. Read those articles and synthesize an answer.
3. Prefer wiki content over your own training knowledge. Cite sources with markdown links: `[Article Title](08-microservices/mcp-service.md)` (paths relative to `klens-knowledge/`).
4. Output the answer in the conversation. Do not write files unless asked.

### Archiving

When the user explicitly asks to archive or save the answer to the wiki:
1. Write the answer as a new wiki article. Place in the most relevant topic folder.
2. File name reflects the query topic, e.g., `mcp-service-overview.md`.
3. Always create a new file. Never merge into existing articles (archive content is a synthesized answer, not raw material).
4. Update `00-index.md`. Prefix the Summary with `[Archived]`.
5. Append to `log.md`:
   ```
   ## [YYYY-MM-DD] query | Archived: <page title>
   ```

---

## Lint

Quality checks on the wiki. Two categories.

### Deterministic Checks (auto-fix)

Fix these automatically:

**Index consistency** — compare `00-index.md` against actual wiki files (excluding `00-index.md` and `log.md`):
- File exists but missing from index → add entry with `(no summary)` placeholder.
- Index entry points to nonexistent file → mark as `[MISSING]` in the index.

**Internal links** — for every markdown link in article files (body text and Sources):
- Target does not exist → search the wiki for a file with the same name elsewhere.
  - Exactly one match → fix the path.
  - Zero or multiple matches → report to the user.

**Orphan cross-refs** — within each topic folder:
- Add missing cross-references between related articles.
- Remove links to deleted files.

### Heuristic Checks (report only)

Report findings without auto-fixing:
- Factual contradictions across articles
- Outdated claims
- Missing cross-topic references (e.g., a microservice article that should link to its infrastructure dependencies but doesn't)
- Orphan pages with no inbound links from other articles
- Concepts frequently mentioned but lacking a dedicated article
- Gaps in coverage (missing topics that should exist based on existing content)

### Post-Lint

Append to `log.md`:
```
## [YYYY-MM-DD] lint | <N> issues found, <M> auto-fixed
```

---

## Conventions

- Standard markdown with relative links throughout.
- Article links use paths relative to `klens-knowledge/`: `[Label](08-microservices/ai-service.md)`.
- In conversation output, use `klens-knowledge/`-relative paths.
- Ingest updates both `00-index.md` and `log.md`. Archive (from Query) updates both. Lint updates `log.md` (and `00-index.md` only when auto-fixing index entries). Plain queries do not write any files.
