---
description: Generate a professional weekly freelance report — work completed, content created, estimated hours, blockers, and next week's plan — and save it to reports/weekly-report-<date>.md.
---

# Weekly Report

Generate a polished, professional weekly report summarizing the week's freelance work. The report should be clean enough to send directly to a client.

## 1. Gather the week's information

Ask the user for the following (accept whatever they provide; if they've already given some in the command, only ask for the gaps):

1. **Work completed** — tasks and deliverables finished this week
2. **Content created** — drafts, posts, assets, or pages produced (check `content/drafts/` and `content/published/` if helpful)
3. **Estimated hours** — time spent, broken down by task if available
4. **Blockers** — anything that slowed progress or needs client input
5. **Next week's plan** — priorities and planned deliverables for the coming week

If a section has nothing to report, write `_None this week_` rather than leaving it blank or inventing items. Do not fabricate work — only summarize what the user provides.

## 2. Generate the report

Produce the report as clean markdown using this structure:

```markdown
# Weekly Report — <Week ending: date>

> Prepared by Jed Quimno · <current date>

## Work Completed
- ...

## Content Created
- ...

## Estimated Hours
| Task | Hours |
| --- | --- |
| ... | ... |
| **Total** | **...** |

## Blockers
- ...

## Next Week's Plan
- ...
```

Use bullet lists for narrative sections and the table for hours. Total the hours if a breakdown is provided.

## 3. Save the file

Save the report to `reports/weekly-report-<date>.md`, where `<date>` is today's date in `YYYY-MM-DD` format. Create the `reports/` directory if it doesn't exist.

After saving, confirm the file path and show a preview of the report.
