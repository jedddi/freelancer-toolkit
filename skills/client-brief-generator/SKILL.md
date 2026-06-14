---
name: client-brief-generator
description: Generate a comprehensive client brief for freelance projects. Use when starting a new client engagement, onboarding a client, or when the user asks to create a client brief, project brief, or scope document. Collects client details and outputs a clean markdown brief saved to client-briefs/<client-name>-brief.md.
---

# Client Brief Generator

Generate a comprehensive, well-structured client brief for a freelance project. The brief captures everything needed to scope the work, align on expectations, and kick off the engagement.

## When to use

Trigger this skill when the user wants to:
- Onboard a new freelance client
- Create a client brief, project brief, or scope document
- Document the requirements for a new engagement

## Workflow

### 1. Gather information

Ask the user for the following details. Present them as a single numbered list so the user can answer all at once, but accept answers given piecemeal too. If the user has already supplied some answers in their request, don't re-ask — only fill the gaps.

1. **Client name** — the company or individual you're working with
2. **Industry** — the client's sector or vertical
3. **Services needed** — what the client is hiring you to do (e.g. web design, copywriting, social media management)
4. **Target audience** — who the client is trying to reach
5. **Brand voice** — tone and personality (e.g. professional, playful, authoritative)
6. **Platforms** — where the work will live or be distributed (e.g. Instagram, LinkedIn, website, email)
7. **Budget range** — the project or retainer budget
8. **Timeline** — start date, key milestones, and deadline
9. **Competitors** — brands the client competes with or admires
10. **Success metrics** — how success will be measured (e.g. leads, engagement rate, conversions, revenue)

If the user leaves a field blank or says "N/A", record it as `_To be determined_` rather than inventing a value. Do not fabricate details — only use what the user provides.

### 2. Generate the brief

Produce the brief as clean markdown. Start with a short header, then present the details as a markdown table.

Use this exact structure:

```markdown
# Client Brief: <Client Name>

> Prepared by Jed Quimno · <current date>

| Field | Details |
| --- | --- |
| **Client Name** | ... |
| **Industry** | ... |
| **Services Needed** | ... |
| **Target Audience** | ... |
| **Brand Voice** | ... |
| **Platforms** | ... |
| **Budget Range** | ... |
| **Timeline** | ... |
| **Competitors** | ... |
| **Success Metrics** | ... |
```

For fields with multiple items (e.g. services, platforms, competitors), separate values with commas or use `<br>` for line breaks within the table cell to keep the table readable.

### 3. Save the file

Save the generated brief to `client-briefs/<client-name>-brief.md`, where `<client-name>` is the client name lowercased with spaces and special characters replaced by hyphens (e.g. "Acme Co." → `acme-co`).

- Create the `client-briefs/` directory if it doesn't exist.
- After saving, confirm the file path to the user and show a preview of the brief.

## Notes

- Keep the table clean and scannable — this is a document the freelancer may share with the client.
- If the user wants to revise a field after generation, update the table and re-save the file.
