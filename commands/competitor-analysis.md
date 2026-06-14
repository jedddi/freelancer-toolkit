---
description: Profile competitors across marketing/positioning, pricing/packaging, and product/features (via the competitor-research-agent), then build a comparison matrix and strategic analysis (via the comparison-analyst-agent), saving outputs under competitor-analysis/.
---

# Competitor Analysis

Orchestrate both subagents to produce a competitor landscape for a client: first profile each competitor across three dimensions with the **competitor-research-agent**, then synthesize those profiles into a comparison matrix and strategic analysis with the **comparison-analyst-agent**. Work through the steps in order.

This pipeline covers exactly **three dimensions** for every competitor — nothing more:

1. **Marketing & positioning** — how they describe themselves, who they target, their core message and differentiators.
2. **Pricing & packaging** — plans, tiers, what's included, billing model.
3. **Product & features** — what the product actually does and its standout capabilities.

A core principle of this plugin applies throughout: **NEVER fabricate.** Only use what the user provides or what is genuinely found via web research. Do not invent competitors, URLs, prices, features, or numbers. Mark any unknown field `_To be determined_` rather than guessing. **Pricing especially** must be marked `_To be determined_` if it is not verified on a real, findable source — never estimate or infer a price.

## 1. Gather inputs

Collect the following:

1. **Client / product context** — who the client is, what they offer, and their target audience (required).
2. **Competitors in mind** — the names and/or URLs the user already has (required: at least one competitor **or** a clearly stated niche to discover competitors from).

If the user already supplied competitors in their command (e.g. `/competitor-analysis Acme Co. — project management for agencies; competitors: Asana, monday.com, https://clickup.com`), use them as given and only ask for the gaps. Do not re-ask for details the user already provided.

You need at minimum the client context plus either one competitor or a clear niche to discover from. If both the competitor list and a usable niche are missing, ask for them before continuing.

## 2. Discover additional competitors

Search the client's niche to identify **2-4 ADDITIONAL** real, findable competitors beyond the ones the user provided. This produces a deliberate **mix** — the user's competitors plus a few discovered ones.

- Only surface competitors that **genuinely exist** and are findable online. **Never invent a competitor** to round out the list.
- Combine the user-supplied competitors with the newly discovered ones into a single list.
- Present the combined list to the user and ask them to **confirm or trim** it before any profiling begins. Do not start profiling until the list is confirmed.

## 3. Profile each competitor

For **each confirmed competitor**, use the **competitor-research-agent** subagent to produce a structured profile across the three dimensions (marketing & positioning, pricing & packaging, product & features). Pass it:

- The **competitor** (name, plus URL if known).
- The **client context** from step 1, so the profile is framed against what the client offers.

Save each returned profile to `competitor-analysis/profiles/<slug>.md`, where `<slug>` is the competitor name lowercased with spaces and special characters replaced by hyphens (e.g. "Acme Co." → `acme-co`). Create the `competitor-analysis/profiles/` directory if it doesn't exist; don't overwrite existing files blindly — if a profile already exists, confirm with the user before replacing it.

Include the byline directly under the H1 of each saved profile:

```markdown
> Prepared by Jed Quimno · <current date>
```

Keep the no-fabrication rule firm: any dimension the agent could not verify stays `_To be determined_`, and unverified pricing is always `_To be determined_`.

## 4. Build the comparison matrix and analysis

Use the **comparison-analyst-agent** subagent to synthesize the profiles into a comparison and strategy. Pass it:

- The **saved profile files** from step 3 (`competitor-analysis/profiles/*.md`).
- The **client context** from step 1.

The agent returns a **comparison matrix table** (competitors as rows or columns across the three dimensions), a **strategic analysis** (where the client can differentiate, gaps and opportunities, threats), and **data-quality notes** that flag which cells are `_To be determined_` so nothing unverified is mistaken for fact.

Save its output to `competitor-analysis/comparison-matrix.md`. Create the `competitor-analysis/` directory if needed; don't overwrite blindly. Include the byline directly under the H1:

```markdown
> Prepared by Jed Quimno · <current date>
```

## 5. Summarize for the user

Give the user a concise, scannable summary:

- The **profile files created** — list each `competitor-analysis/profiles/<slug>.md` path.
- The **matrix file path** — `competitor-analysis/comparison-matrix.md`.
- The **top 3 takeaways** from the comparison-analyst-agent's strategic analysis.
- **Suggested next steps** — e.g. manually validate pricing before sharing, fill in any `_To be determined_` cells, and share the matrix with the client.

Keep the no-fabrication principle in mind to the very end: flag every field left as `_To be determined_` (pricing especially) so the user can verify it before this goes in front of the client.
