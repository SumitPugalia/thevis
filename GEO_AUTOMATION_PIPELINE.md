# Connecting and Automating the Six-Step GEO Workflow

**Question:** Is it possible to connect all 6 steps and automate the workflow?

**Short answer:** **Yes, for most of it.** We can **connect** the steps into an orchestrated pipeline and **automate** everything that doesn’t require human judgment, relationships, or policy. Some actions must stay **manual** by nature (see below).

---

## What Can Be Automated (and How)

| Step | What to automate | How (existing or new) |
|------|------------------|------------------------|
| **1. Define entity** | Create company, products, project | ✅ Already in platform (onboarding, CRUD). |
| | Suggest entity block when empty | ✅ “Suggest with AI” on Edit Company. **New:** Optional auto-suggest on company create (background job or on first edit). |
| | Choose optimizable type | ⚠️ **Manual** – business decision (product vs service). Could default from company_type. |
| **2. Baseline** | Run entity probe + recall (baseline scan) | ✅ Scans exist; user triggers. **New:** Auto-trigger baseline scan when project is created (Oban job after `create_project_for_product`). |
| | GEO Score, report, dashboard | ✅ Already automated. |
| | Identify gaps | ⚠️ **Manual** – consultant interprets. **Optional:** LLM job that compares entity snapshot to entity block and suggests fixes (stored as “suggestions” for consultant). |
| **3. Entity & answer content** | Sync description in platform | ✅ Edit company/product. |
| | Generate definitions/FAQs from entity block | ✅ Content generation + narratives exist. **New:** Ensure narrative/playbook uses company one_line_definition, problem_solved, key_concepts. |
| | Publish to blog/GitHub/Medium | ✅ Content publishing job. |
| | Finalize entity block | ⚠️ **Manual** – human agrees wording. Platform can suggest and store. |
| **4. Authority** | Wikis (create/sync/publish) | ✅ Wiki jobs, campaign orchestration. |
| | Content + citations | ✅ Content generation, citation generator, campaigns. |
| | Create/run campaigns | ✅ CampaignOrchestrator, CampaignExecution job. **New:** Auto-create a “default” campaign when project is created (or when baseline scan completes and score is low). |
| | Link building, PR, Wikipedia | ❌ **Manual** – relationships, policies, outreach. |
| **5. Distribution** | Configure integrations | ⚠️ **Manual** one-time (API keys). Platform stores config. |
| | Publish generated content | ✅ Content publishing. |
| | Sync profile text (where API allows) | ✅ Integrations exist; can be triggered from campaign or “sync” action. |
| | Align third-party profiles (G2, Capterra, etc.) | ⚠️ **Manual** (most) – many no API; platform can show “tasks” for consultant. |
| | Community & Q&A | ❌ **Manual** – authentic participation; automation would be spam. |
| **6. Reinforce & monitor** | Repeat entity in content | ✅ Generated content uses narrative/entity block. |
| | Run recurring scans | ✅ `schedule_recurring_scan(project)` exists; needs to be **triggered** (e.g. after first scan completes, or via Oban cron). |
| | Compare GEO Score over time | ✅ Dashboard, project show, PDF report. |
| | Run “monitoring prompts” in LLMs | **New:** Automate – same as recall test: run fixed prompts (e.g. “Best [category] products?”) via AI adapter, store whether client is mentioned and rank. Dashboard “Monitoring” tab. |
| | Tune narratives and prompts | ⚠️ **Manual** – consultant decides. Optional: LLM suggests edits from drift/gaps. |

---

## What Must Stay Manual (and Why)

| Action | Why manual |
|--------|------------|
| Choose optimizable type (product vs service) | Business/positioning decision. |
| Finalize entity block wording | Legal/brand; human must agree. |
| Interpret scan gaps and plan strategy | Consultant judgment. |
| Link building, PR, earned media | Relationships, outreach, negotiation. |
| Wikipedia / high-authority wikis | Notability, NPOV, citations – policy and human editing. |
| Align third-party profiles (many directories) | No API or limited; manual form filling. |
| Community & Q&A (Reddit, Quora, etc.) | Authentic participation; bots = spam/ban. |
| Configure API keys / integrations | Security, one-time setup. |
| Tune narratives and recall prompts | Strategy; human decides what to change. |

---

## Pipeline: Connecting the Six Steps

Goal: **One flow** where completing Step N can automatically trigger or schedule Step N+1 where it makes sense.

```
Step 1 (Define entity)
  → Company/Product/Project created
  → [NEW] Optional: if entity block empty, suggest via LLM (or prompt admin)
  → [NEW] On project create: schedule baseline scan (Step 2)

Step 2 (Baseline)
  → Scan runs (entity probe + recall)
  → GEO Score, report, dashboard updated
  → [NEW] Optional: if score low and no campaign yet, create default campaign or notify consultant (Step 4)
  → [NEW] Schedule first recurring scan (Step 6) if project has scan_frequency

Step 3 (Entity & answer content)
  → Consultant/client finalize entity block in platform
  → Narrative/playbook uses entity block
  → Campaigns generate content (Step 4)

Step 4 (Authority)
  → Campaign runs: content generation → publishing (wiki, blog, GitHub, Medium)
  → [Existing] CampaignOrchestrator, jobs
  → Manual: link building, PR, Wikipedia

Step 5 (Distribution)
  → Published content goes to configured channels (existing)
  → Sync profile text where API allows (existing integrations)
  → Manual: third-party profiles, community

Step 6 (Reinforce & monitor)
  → Recurring scans (existing schedule_recurring_scan; needs trigger)
  → [NEW] Optional: scheduled “monitoring prompts” job (recall-style, store results)
  → Dashboard shows GEO Score over time
  → Manual: consultant runs ad-hoc prompts in ChatGPT/Perplexity; tunes narratives
```

---

## Implementation Roadmap

### Phase A – Connect triggers (high impact, low risk) ✅ Implemented

1. **On project creation:** ✅ After `Projects.create_project_for_product`, `Automation.Schedules.create_schedules_for_project(project)` creates a baseline_scan (once) and recurring_scan schedule; baseline is run immediately via `run_now(baseline_schedule)` so a full scan is queued. Recurring scan uses project’s `scan_frequency` and is processed by the periodic worker.
2. **Recurring scans:** ✅ A `ProcessAutomationSchedules` Oban worker runs every 10 minutes (reschedules itself), calls `Schedules.process_due_schedules/0`, which enqueues due scans and updates `next_run_at` / `last_run_at`. No separate “after first scan completes” trigger; the schedule table is the source of truth.
3. **Optional – entity block suggest:** Keep current “Suggest with AI” button on admin company edit only.

### Phase B – Scheduled monitoring (Step 6)

4. **Monitoring prompts job:** New Oban job (e.g. weekly) that, for each active project, runs 2–3 fixed “monitoring” prompts (e.g. “What are the best [category] products?”) via the AI adapter, parses whether the client/product is mentioned and at what rank, and stores results (new table or scan_result-style). Dashboard “Monitoring” or “LLM mentions” view. (Schedule type `monitoring_prompts` exists in `automation_schedules`; job not yet implemented.)
5. **Recurring scans enqueued:** ✅ Handled by `automation_schedules` table and `ProcessAutomationSchedules` worker; no separate cron needed.

### Phase C – Optional full-auto mode

6. **Default campaign on project:** When a project is created (or when baseline GEO Score &lt; threshold), auto-create a “GEO baseline” campaign (or a single content + wiki task) so consultant can “Start” with one click.
7. **Gap suggestions:** After a scan, optional job that compares entity snapshot to company one_line_definition and produces “suggestions” (e.g. “AI says X; entity block says Y; consider aligning”) for consultant review.

---

## Summary

| Question | Answer |
|----------|--------|
| Can we **connect** all 6 steps? | **Yes** – via triggers (project created → baseline scan; scan completed → schedule recurring; campaigns → publish; recurring scans + monitoring job). |
| Can we **automate** all 6 steps? | **Mostly.** Automate: entity CRUD, entity block suggest, baseline scan, recurring scans, content generation, wikis, campaigns, publishing, monitoring prompts (new). Keep manual: choose optimizable type, finalize wording, interpret gaps, link building, PR, Wikipedia, third-party profiles, community, config, tune narratives. |
| What to build next? | Phase A ✅ Done. Admin can view/control schedules at `/admin/scheduled-tasks` (enable/disable, edit frequency, run now, delete). Then Phase B (monitoring prompts job + dashboard). Then Phase C (default campaign, gap suggestions) if desired. |

This document is the **single place** for: what can be automated, what must stay manual, and how to connect the six steps into one pipeline.
