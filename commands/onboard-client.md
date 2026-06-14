---
description: Walk through onboarding a new freelance client — collect their details, generate a client brief, scaffold the project folder structure, save the brief, and summarize next steps.
---

# Onboard Client

Guide the user through onboarding a new freelance client from start to finish. Work through the steps in order.

## 1. Gather client details

Ask the user for:

1. **Client name** — the company or individual
2. **Services** — what the client is hiring them to do

If the user already provided either in their command (e.g. `/onboard-client Acme Co. — social media management`), use it and only ask for what's missing. Don't re-ask for details already given.

## 2. Generate the client brief

Use the **client-brief-generator** skill to produce a comprehensive brief. If the user only supplied name and services, gather the remaining brief fields (industry, target audience, brand voice, platforms, budget range, timeline, competitors, success metrics) as that skill directs. Mark anything unknown as `_To be determined_` rather than inventing values.

## 3. Create the project folder structure

Create these folders for the engagement (create parent directories as needed; don't overwrite anything that already exists):

- `client-briefs/`
- `content/drafts/`
- `content/published/`
- `reports/`

## 4. Save the brief

Save the generated brief to `client-briefs/<client-name>-brief.md`, where `<client-name>` is the client name lowercased with spaces and special characters replaced by hyphens (e.g. "Acme Co." → `acme-co`).

## 5. Summarize next steps

Confirm what was created and lay out clear next steps. Include:

- The path to the saved brief
- The folder structure that was created
- Suggested next actions — e.g. review the brief with the client, fill in any `_To be determined_` fields, start the first draft in `content/drafts/`, and schedule the first `/weekly-report`

Keep the summary concise and scannable.
