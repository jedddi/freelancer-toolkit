# Freelancer Toolkit

A freelancer's toolkit for **client onboarding, content creation, and project management** — packaged as a Claude Code plugin.

It bundles four slash commands, a skill, four specialized subagents, two automation hooks, and a GitHub MCP connection into one install. A principle runs through all of it: **never fabricate.** Every command and agent is built to use only what you provide or what is genuinely found via research, and to mark anything unverified as `_To be determined_` rather than guess.

---

## What's inside

| Type | Name | What it does |
| --- | --- | --- |
| Command | `/onboard-client` | Walks through onboarding a new client: collects details, generates a brief, scaffolds the project folders, and summarizes next steps. |
| Command | `/research-and-write` | Researches a topic (research-agent), writes an 800–1200 word blog post grounded in credible sources, then reviews it for SEO and accuracy (review-agent). Saves the draft to `content/drafts/`. |
| Command | `/competitor-analysis` | Profiles competitors across marketing/positioning, pricing/packaging, and product/features (competitor-research-agent), then builds a comparison matrix and strategic analysis (comparison-analyst-agent). Saves outputs under `competitor-analysis/`. |
| Command | `/weekly-report` | Generates a polished weekly report (work completed, content, hours, blockers, next week's plan) ready to send to a client. |
| Skill | `client-brief-generator` | Produces a comprehensive client brief and saves it to `client-briefs/<client-name>-brief.md`. |
| Agent | `research-agent` | Finds 3–5 credible, real sources for a topic and returns structured, attributed summaries. Never fabricates sources or facts. |
| Agent | `review-agent` | Editorial, SEO, and accuracy reviewer for drafts — returns per-dimension findings and a 1–10 score with prioritized fixes. |
| Agent | `competitor-research-agent` | Profiles a single competitor across positioning, pricing, and features, marking anything unverified (pricing especially) as `_To be determined_`. |
| Agent | `comparison-analyst-agent` | Synthesizes competitor profiles into a comparison matrix plus a strategic analysis of where the client can differentiate. |
| Hook (PostToolUse) | `quality-check` | After any `Write` or `Edit` to a content file, warns on low word count and flags placeholder text. |
| Hook (Stop) | `session-summary` | When a session ends, prints a summary of what was accomplished — files created/edited, commands run, and a tool-call breakdown. |
| MCP server | `github` | Connects Claude to GitHub (repos, issues, PRs, code) via the official GitHub MCP server. |

---

## Installation

### Prerequisites

- **Claude Code** installed and working (`claude --version`).
- **`bash`** available on your `PATH` — the hooks are shell scripts. On Windows, use **Git Bash** or **WSL**.
- *(Optional)* [**`jq`**](https://jqlang.github.io/jq/) for the cleanest hook output (the scripts fall back to `grep`/`sed` without it).
- *(Optional)* A **GitHub Personal Access Token** if you want the bundled `github` MCP server — see [How the MCP server works](#how-the-mcp-server-works-github).

### Add the marketplace and install

This repo is a self-contained, single-plugin marketplace. Add it, then install the plugin from it.

**From GitHub:**

```bash
# 1. Register this repo as a marketplace
claude plugin marketplace add jedddi/freelancer-toolkit

# 2. Install the plugin from it
claude plugin install freelancer-toolkit@jed-quimno-plugins
```

**From a local clone:**

```bash
git clone https://github.com/jedddi/freelancer-toolkit.git
claude plugin marketplace add ./freelancer-toolkit
claude plugin install freelancer-toolkit@jed-quimno-plugins
```

> The marketplace is named `jed-quimno-plugins` and the plugin is named `freelancer-toolkit`, so the fully-qualified install target is `freelancer-toolkit@jed-quimno-plugins`.

### Verify

Restart Claude Code, then confirm the plugin loaded:

```bash
claude plugin list
```

You should see `freelancer-toolkit` enabled. Type `/` in a session and you'll see `/onboard-client`, `/research-and-write`, `/competitor-analysis`, and `/weekly-report` in the command list.

### Updating / removing

```bash
claude plugin update freelancer-toolkit      # pull the latest version (restart to apply)
claude plugin uninstall freelancer-toolkit   # remove it
```

---

## Slash commands

All four commands are conversational — they ask for anything they need. If you pass details inline with the command, they use what you gave and only ask for the gaps. None of them invent information: missing fields are recorded as `_To be determined_`.

### `/onboard-client` — onboard a new client end to end

Takes a client from "just signed" to a ready-to-work project folder.

**Usage**

```
/onboard-client Acme Co. — social media management
```

**What it does**

1. Collects the **client name** and **services** (asks for anything you didn't supply).
2. Runs the **`client-brief-generator`** skill to build a full brief, gathering the remaining fields (industry, target audience, brand voice, platforms, budget, timeline, competitors, success metrics).
3. Scaffolds the engagement's folder structure (`client-briefs/`, `content/drafts/`, `content/published/`, `reports/`) without overwriting anything that already exists.
4. Saves the brief to `client-briefs/<client-name>-brief.md`.
5. Summarizes what was created and the recommended next steps.

**Output:** `client-briefs/acme-co-brief.md` plus the project folder structure.

---

### `/research-and-write` — research, draft, and review a blog post

Produces a reviewed, publication-ready blog post grounded in real sources.

**Usage**

```
/research-and-write the rise of AI agents in customer support
```

You can also supply optional context: **target keyword(s)**, **audience**, and **tone**.

**What it does**

1. **Research** — the **`research-agent`** finds 3–5 credible sources and returns attributed summaries plus key themes. If it finds fewer than three, it tells you and asks whether to proceed or refine the topic — it never pads the list.
2. **Write** — drafts an **800–1200 word** SEO-structured post (H1, hook intro, logical H2/H3s, conclusion + CTA, natural keyword usage). Every claim traces back to a research source, and the post ends with a `## Sources` list.
3. **Save** — writes the draft to `content/drafts/<slug>.md` with a byline.
4. **Review** — the **`review-agent`** scores the draft **1–10** across SEO, accuracy, and quality, with a prioritized fix list.
5. **Revise once** — if the score is below 8/10, it revises a single time against the top fixes and re-saves. It never loops indefinitely.

**Output:** `content/drafts/<slug>.md` plus a review score (e.g. `7/10 → 9/10`).

---

### `/competitor-analysis` — build a competitor landscape for a client

Profiles competitors and turns them into a decision-ready comparison and strategy.

**Usage**

```
/competitor-analysis Acme Co. — project management for agencies; competitors: Asana, monday.com, https://clickup.com
```

You need, at minimum, the **client/product context** plus either **one competitor** or a **clear niche** to discover competitors from.

**What it does**

1. **Gather inputs** — client context and any competitors you already have in mind.
2. **Discover** — searches the niche for **2–4 additional** real, findable competitors, then asks you to **confirm or trim** the combined list before any profiling.
3. **Profile** — runs the **`competitor-research-agent`** once per confirmed competitor across three dimensions (marketing & positioning, pricing & packaging, product & features), saving each to `competitor-analysis/profiles/<slug>.md`.
4. **Synthesize** — the **`comparison-analyst-agent`** builds a comparison matrix and strategic analysis, saved to `competitor-analysis/comparison-matrix.md`, with data-quality notes flagging every `_To be determined_` cell.
5. **Summarize** — lists the files created, the top takeaways, and suggested next steps.

> **Pricing is never guessed.** Any price not verified on a real, findable source is marked `_To be determined_` so you can validate it before it reaches the client.

**Output:** `competitor-analysis/profiles/<slug>.md` (one per competitor) and `competitor-analysis/comparison-matrix.md`.

---

### `/weekly-report` — generate a client-ready weekly report

Turns the week's work into a polished report you can send as-is.

**Usage**

```
/weekly-report
```

**What it does**

1. Collects (or asks for) **work completed**, **content created**, **estimated hours**, **blockers**, and **next week's plan**. It can check `content/drafts/` and `content/published/` to help. Empty sections become `_None this week_` rather than invented filler.
2. Generates a clean markdown report with bullet sections and an hours table (totaled if a breakdown is given).
3. Saves it to `reports/weekly-report-<YYYY-MM-DD>.md` and shows a preview.

**Output:** `reports/weekly-report-2026-06-14.md` (dated to the day you run it).

---

## The skill

### `client-brief-generator`

A standalone [Agent Skill](https://docs.claude.com/en/docs/claude-code/skills) that produces a comprehensive client brief. It's invoked automatically by `/onboard-client`, but it also triggers on its own whenever you ask Claude to "create a client brief," "scope a new engagement," or similar.

It collects up to ten fields (client name, industry, services, audience, brand voice, platforms, budget, timeline, competitors, success metrics), renders them as a clean markdown table, and saves the result to `client-briefs/<client-name>-brief.md`. Blank or N/A fields are recorded as `_To be determined_` — never fabricated.

---

## The agents

The plugin ships four subagents. You normally don't call them directly — the commands delegate to them — but you can invoke any of them yourself when you just need that one capability (e.g. "use the review-agent to check this draft").

| Agent | Role | Tools |
| --- | --- | --- |
| `research-agent` | Find and summarize 3–5 credible sources for a topic. | WebSearch, WebFetch, Read |
| `review-agent` | Editorial / SEO / accuracy review with a 1–10 score and prioritized fixes. | Read, WebSearch, WebFetch |
| `competitor-research-agent` | Profile a single competitor across three dimensions. | WebSearch, WebFetch, Read |
| `comparison-analyst-agent` | Synthesize profiles into a comparison matrix + strategy. | Read, WebSearch, WebFetch |

Each agent enforces the no-fabrication rule independently: they only report what they actually read, attribute every claim to a source, and mark anything unverifiable rather than guessing.

---

## How the MCP server works (GitHub)

This plugin ships a [`.mcp.json`](.mcp.json) that connects Claude Code to the official **GitHub MCP server**, letting Claude read and act on your repositories, issues, and pull requests.

The config references a credential through an environment variable rather than hard-coding it, so your token never lives in the repo:

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

When the plugin is enabled, Claude Code discovers this server automatically and substitutes `${GITHUB_PERSONAL_ACCESS_TOKEN}` from your environment at launch. If the variable isn't set, the server simply won't authenticate — the rest of the plugin still works.

### 1. Create a GitHub Personal Access Token

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**
   (direct link: <https://github.com/settings/personal-access-tokens/new>).
2. Click **Generate new token**.
3. Give it a name (e.g. `claude-code-mcp`) and an expiration.
4. Under **Repository access**, choose the repositories you want Claude to reach (or *All repositories*).
5. Under **Permissions**, grant the scopes you need. A typical read/write setup:
   - **Contents** — Read and write
   - **Issues** — Read and write
   - **Pull requests** — Read and write
   - **Metadata** — Read-only (required, granted automatically)
6. Click **Generate token** and **copy it** — you won't be able to see it again.

> Prefer the least privilege that gets the job done. If you only need Claude to read code and issues, grant read-only scopes.

### 2. Set the environment variable

The token must be available as `GITHUB_PERSONAL_ACCESS_TOKEN` in the environment where you launch Claude Code.

**Windows (PowerShell)** — set it for your user account so it persists across sessions:

```powershell
setx GITHUB_PERSONAL_ACCESS_TOKEN "ghp_your_token_here"
```

Then **open a new terminal** for the change to take effect. To set it for the current session only:

```powershell
$env:GITHUB_PERSONAL_ACCESS_TOKEN = "ghp_your_token_here"
```

**macOS / Linux (bash or zsh)** — add this to your `~/.bashrc`, `~/.zshrc`, or `~/.profile`:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_token_here"
```

Then reload your shell (`source ~/.zshrc`) or open a new terminal.

> **Never commit your token.** Keep it in your environment only. If a token is ever exposed, revoke it immediately in GitHub settings and generate a new one.

### 3. Restart Claude Code and approve the server

After the environment variable is set, restart Claude Code. When the `github` MCP server is detected, approve it when prompted. Confirm it's connected by running:

```
/mcp
```

You should see `github` listed as connected, along with its available tools.

---

## How hooks work

The plugin registers two hooks in [hooks/hooks.json](hooks/hooks.json). Both are shell scripts that run wherever `bash` is available (Git Bash or WSL on Windows). They use [`jq`](https://jqlang.github.io/jq/) when installed for the most accurate parsing and fall back to `grep`/`sed` otherwise — so `jq` is optional but recommended.

Each hook receives the event payload as JSON on **stdin** and is invoked via `${CLAUDE_PLUGIN_ROOT}`, so it works no matter where the plugin is installed.

### `quality-check` — `PostToolUse` (matches `Write` and `Edit`)

After Claude writes or edits a file, this hook inspects the result if it's a content file (`.md`, `.txt`, `.html`) and surfaces warnings back to Claude:

- **Low word count** — warns if the file is under **200 words**.
- **Placeholder text** — flags leftover `lorem ipsum` or `TODO` markers, with line numbers.

It's non-blocking — the write has already happened — but it prints warnings to stderr (exit code 2) so Claude sees them and can fix the content. Files of other types are skipped.

### `session-summary` — `Stop`

When a session ends, this hook reconstructs a recap from the session transcript and prints:

- **Files created/edited** (distinct paths from `Write`/`Edit`/`MultiEdit`/`NotebookEdit`).
- **Commands run** (count of `Bash` calls).
- **Tool-call breakdown** (e.g. `12× Read, 5× Edit, 3× Bash`).

It never prevents Claude from stopping. The summary appears in the **transcript view** — press **Ctrl-R** to see it.

---

## Project structure created at runtime

The commands scaffold this structure in your working directory as you use them:

```
client-briefs/         # generated client briefs        (/onboard-client, client-brief-generator)
content/drafts/        # in-progress content             (/research-and-write)
content/published/     # shipped content
reports/               # weekly reports                  (/weekly-report)
competitor-analysis/
├── profiles/          # per-competitor profiles         (/competitor-analysis)
└── comparison-matrix.md
```

Folders are created on demand and never overwrite existing files blindly.

---

## A note on the no-fabrication principle

Everything here is designed to be **client-ready and trustworthy**. Across every command, skill, and agent:

- Only information you provide or that is genuinely found via research is used.
- Unknown fields are marked `_To be determined_` (or `_Unverified_` / `_None this week_`) — never invented.
- **Pricing and factual claims** get the strictest treatment: if a value isn't verified on a real source, it's flagged, not guessed.

Before sending any generated document to a client, scan for these markers and fill them in.

---

## Author

Jed Quimno — <jedquimno7@gmail.com>
