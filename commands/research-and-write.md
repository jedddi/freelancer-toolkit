---
description: Research a topic with the research-agent, write an 800-1200 word blog post grounded in credible sources, then review it for SEO and accuracy with the review-agent (1-10 score with prioritized fixes), saving the draft to content/drafts/.
---

# Research and Write

Orchestrate both subagents to produce a reviewed, publication-ready blog post: first research the topic with the **research-agent**, then write a draft grounded in those sources, then score and refine it with the **review-agent**. Work through the steps in order.

A core principle of this plugin applies throughout: **NEVER fabricate.** Only use what the user provides or what the research-agent genuinely finds. Every factual claim in the post must trace back to a source the research-agent returned. Do not invent sources, facts, statistics, quotes, or URLs. Mark anything genuinely unknown as `_To be determined_` rather than guessing.

## 1. Gather inputs

Collect the following:

1. **Topic** — what the post is about (required)
2. **Target keyword(s)** — the SEO term(s) to rank for (optional)
3. **Audience** — who the post is written for (optional)
4. **Tone** — the desired voice, e.g. professional, conversational, authoritative (optional)

If the user already supplied the topic in their command (e.g. `/research-and-write the rise of AI agents in customer support`), use it as the topic and only ask for the gaps. Do not re-ask for details the user already gave. If the topic is missing, ask for it before continuing. The optional fields can be left blank — proceed without them rather than inventing them.

## 2. Research the topic

Use the **research-agent** subagent to find **3-5 credible sources** with summaries on the topic. Pass it the topic and any target keyword(s) and audience gathered in step 1.

- If the research-agent returns **fewer than 3 credible sources**, surface that to the user plainly (state how many were found) and ask whether to **proceed with what's available** or **refine the topic**. Do not pad the list with weak or invented sources to reach three.
- Carry the returned sources (titles, URLs, and summaries) and the **Key themes** synthesis forward — the draft and the review both depend on them.

## 3. Write the blog post

Produce an **800-1200 word** blog post that is **grounded in the research** from step 2. Every claim must be supported by one of the research-agent's sources — attribute claims to those sources and do not introduce facts the research did not surface.

Use an SEO-friendly structure:

- A compelling **H1** title
- A strong **intro** that hooks the reader and states what the post covers
- Logical **H2/H3 sections** that organize the body
- A **conclusion** with a clear takeaway and a call to action (CTA)
- **Natural keyword usage** — weave the target keyword(s) in where they read naturally; never keyword-stuff
- Apply the requested **tone** and write for the stated **audience** if provided

End the post with a short **`## Sources`** list that links the research-agent's sources (title + URL for each). Only list sources the research-agent actually returned.

## 4. Save the draft

Save the post to `content/drafts/<slug>.md`, where `<slug>` is the topic lowercased with spaces and special characters replaced by hyphens (e.g. "The Rise of AI Agents" → `the-rise-of-ai-agents`). Create the `content/drafts/` directory if it doesn't exist. Include the byline directly under the H1:

```markdown
> Prepared by Jed Quimno · <current date>
```

## 5. Review the draft

Use the **review-agent** subagent to check the saved draft for **SEO and accuracy**. Pass it the saved draft file and the research sources from step 2. The review-agent returns a **1-10 quality score** with a prioritized list of fixes (highest-impact first), flagging any claim that is unsupported by the sources.

## 6. Revise if needed

If the score is **below 8/10**, revise the draft **once** to address the review-agent's top fixes, then re-save it to the same path. Note what changed. Stay grounded in the existing sources — do not invent new facts or sources while revising. **Do not loop indefinitely**: revise at most one time, even if the score is still below 8 afterward.

If the score is **8/10 or higher**, no revision is needed.

## 7. Summarize for the user

Give the user a concise, scannable summary:

- The **saved file path** (`content/drafts/<slug>.md`)
- The **topic**
- The **number of sources used**
- The **review score** — before, and after any revision (e.g. `7/10 → 9/10`, or just the single score if no revision was needed)
- **Suggested next steps** — e.g. a human fact-check of the cited claims, adding images, and moving the post to `content/published/` once approved

Keep the no-fabrication principle in mind to the very end: flag anything left as `_To be determined_` so the user can fill it in before publishing.
