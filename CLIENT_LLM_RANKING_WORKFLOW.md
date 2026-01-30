# Client LLM Ranking Workflow

**Purpose:** Step-by-step workflow to make your clients rank better in LLMs (ChatGPT, Gemini, Perplexity, Copilot, Claude). For each step we indicate whether it is **automated in the platform** or **manual** (client/consultant action).

**Audience:** Consultants and internal teams running GEO for clients; can be shared in part with clients to set expectations.

---

## Workflow status: What’s automated vs manual

- **We are not “done” in the sense of making everything automated.** Several actions are **manual by design** (e.g. choose optimizable type, interpret gaps, link building, PR, Wikipedia, community/Q&A, run monitoring prompts in LLMs, tune narratives).
- **The platform implements the “Automated in platform” actions** below (company/product/project CRUD, entity block fields, scans, GEO Score, wikis, content generation, campaigns, publishing, integrations, reports). The “Manual” actions are done by consultants or clients outside the platform (or partly assisted, e.g. entity block suggested by LLM from the admin panel).
- **Summary:** Steps 1–6 are **supported** by the workflow and the platform; within each step, the tables and the Summary Table define what is **automated in the platform** vs **manual**. Use this doc to set expectations and to see what the platform does vs what people do.

---

## Overview: Why Clients Need This

LLMs answer user questions by retrieving and citing sources. If a client’s product or company is not clearly defined, not present in trusted sources, or described inconsistently, they won’t be mentioned or will be described wrongly. This workflow fixes that in order:

1. **Define the entity** (what we optimize)
2. **Measure baseline** (how AI sees them today)
3. **Fix entity & answer content** (one-line definition, FAQs, structure)
4. **Build authority** (wikis, content, citations)
5. **Distribute** (same message everywhere AI looks)
6. **Reinforce & monitor** (repeat, re-scan, tune)

---

## Step-by-Step Workflow

---

### Step 1: Define the entity (what to optimize)

**Goal:** Decide *what* should be visible to AI: a product, a product category, or the company (service).

| Action | Description | Automated in platform? | Notes |
|--------|-------------|------------------------|-------|
| Choose optimizable type | Product-based (optimize product(s)) vs service-based (optimize company). | **Manual** | Consultant/client decide from positioning and search intent. |
| Create company | Add company in thevis (name, industry, description). | **Platform** | Onboarding / Companies. |
| Add products or services | Add products (name, description, category) or services. | **Platform** | Products, Services. |
| Create project | Link project to the optimizable (product or company). | **Platform** | Projects. |
| Write “entity block” | One-line definition, category, problem solved, key concepts (see GEO_ENTITY_BLOCK style). | **Manual** / **Platform** (assist) | Consultant/client draft; store in company (category, one_line_definition, problem_solved, key_concepts). Admin can use “Suggest with AI” on Edit Company to have the LLM suggest the three optional fields, then edit and save. |

**Output:** Company and product(s)/service(s) in the platform; project created; clear entity block (one-line definition, category) to reuse everywhere.

---

### Step 2: Establish baseline (how AI sees them today)

**Goal:** Measure current AI visibility before any optimization.

| Action | Description | Automated in platform? | Notes |
|--------|-------------|------------------------|-------|
| Run entity probe | Ask AI “What is [product/company name]?” and capture description + confidence. | **Platform** | Scan type: entity probe. Produces entity snapshot. |
| Run recall test | Run prompts (e.g. “Best [category] products?”) and check if entity is mentioned. | **Platform** | Part of scan (recall). Produces recall %, first-mention rank. |
| Run full or authority/consistency scan | Optional: authority sources, consistency/drift vs reference description. | **Platform** | Scan types: authority, consistency, full. |
| Review GEO Score & report | GEO Score (0–100), recall %, first-mention rank, “How AI describes you.” | **Platform** | Dashboard, project GEO Audit Summary, Export PDF Report. |
| Identify gaps | Wrong/missing description, low recall, high drift. | **Manual** | Consultant interprets snapshot and recall results; list fixes. |

**Output:** Baseline GEO Score and metrics; entity snapshot; list of gaps (wrong definition, low recall, inconsistency).

---

### Step 3: Lock entity definition and answer-first content

**Goal:** One canonical definition and answer-style content so AI can quote the client correctly.

| Action | Description | Automated in platform? | Notes |
|--------|-------------|------------------------|-------|
| Finalize entity block | One-line definition, category, problem solved, key concepts—same everywhere. | **Manual** | Client/consultant agree; update company/product description in platform. |
| Add definitions & FAQs | e.g. “What is [product]?”, “What does [company] do?” with direct answers. | **Manual** (content) / **Platform** (publish) | Client site, blog, or wiki. Platform can publish generated content to GitHub, Medium, blog. |
| Structure content for retrieval | H1 = question or claim; H2s = definition, how it works, FAQs. No fluff intros. | **Manual** (strategy) / **Platform** (templates) | Narratives and playbooks drive generated content structure. |
| Sync description in platform | Ensure product/company description in thevis matches entity block. | **Platform** | Edit company/product; used in narratives and probes. |

**Output:** Single entity block in thevis and on key assets; answer-first pages (definitions, FAQs) live on client site or published via platform.

---

### Step 4: Build authority (wikis, content, citations)

**Goal:** Create and maintain sources AI trusts: wikis, citable content, structured references.

| Action | Description | Automated in platform? | Notes |
|--------|-------------|------------------------|-------|
| Add wiki platforms & pages | Configure wiki platforms; create pages that define the entity. | **Platform** (management) | Consultant: Wiki Management. Create/sync pages. |
| Generate wiki content from narrative | Draft wiki content from project narrative and entity block. | **Platform** | Wiki creation/sync jobs; content from narratives/playbooks. |
| Publish/update wikis | Publish new or updated wiki pages to configured platforms. | **Platform** | Wiki creation, wiki publishing, wiki sync jobs. |
| Generate blog/docs/README content | Blog posts, GitHub READMEs, Medium-style content from narratives/playbooks. | **Platform** | Content generation job; content helpers, narratives. |
| Add citations (author, source, date) | Make content look citable (author, source, date). | **Platform** | Citation generator; used in generated content. |
| Publish content to channels | Push content to GitHub, Medium, blog (when configured). | **Platform** | Content publishing job; GitHub/Medium/Blog integrations. |
| Create/run campaigns | Run campaigns (content, authority, consistency, full). | **Platform** | Campaign management; campaign execution job. |
| Link building / PR / earned media | Outreach, press releases, guest posts, backlinks. | **Manual** | Platform can track; execution is client/agency. |
| Wikipedia / high-authority wikis | Create or update Wikipedia (or similar) where eligible. | **Manual** | Policy and notability; consultant/client. |

**Output:** Wikis and citable content live; campaigns running; authority sources growing. Link/PR work tracked or done manually.

---

### Step 5: Distribute (same entity everywhere)

**Goal:** Same entity block and key messages on every channel AI might read.

| Action | Description | Automated in platform? | Notes |
|--------|-------------|------------------------|-------|
| Configure platform integrations | GitHub, Medium, blog, LinkedIn, G2, Capterra, Crunchbase, Product Hunt, etc. | **Platform** (config) | Consultant: Platform Settings; API keys, profile IDs. |
| Sync profile text (where API allows) | Update “about” / description on LinkedIn, Twitter, Facebook, etc. from narrative. | **Platform** (when integrated) | Integrations fetch/sync; publishing can push description. |
| Publish generated content | Blog, GitHub README, Medium articles with entity block and definitions. | **Platform** | Content publishing job. |
| Align third-party profiles | G2, Capterra, Trustpilot, Crunchbase, Product Hunt—description and category. | **Manual** (most) / **Platform** (some) | Many are manual or limited API; platform can track. |
| Community & Q&A | Reddit, Quora, Stack Exchange—high-quality answers that mention client. | **Manual** | Platform can monitor; writing and posting manual. |

**Output:** Entity block and key messages consistent on owned channels and, where possible, on directories/review sites; community presence where manual work is done.

---

### Step 6: Reinforce and monitor (repeat, re-scan, tune)

**Goal:** Repeat the same phrases and definitions; re-measure; adjust until GEO improves.

| Action | Description | Automated in platform? | Notes |
|--------|-------------|------------------------|-------|
| Repeat entity block in content | Use same one-line definition and category in wikis, blog, social, directories. | **Platform** (generated) / **Manual** (social, some directories) | Narratives and playbooks drive consistency in platform-generated content. |
| Run recurring scans | Entity probe + recall (and optional authority/consistency) on a schedule. | **Platform** | Run scans periodically; compare GEO Score over time. |
| Compare GEO Score & recall | Track GEO Score, recall %, first-mention rank run-over-run. | **Platform** | Dashboard and project show; PDF report. |
| Run “monitoring prompts” in LLMs | e.g. “Best [category] products?”, “What is [product]?” in ChatGPT, Perplexity, etc. | **Manual** | Consultant or client; log whether client is mentioned and how. |
| Tune narratives and prompts | If AI description is wrong or recall low, refine entity block and recall prompts. | **Manual** | Consultant updates narrative and/or recall prompt set; re-scan. |

**Output:** GEO Score and recall trending up; monitoring prompts show client mentioned and described correctly; narratives and prompts refined when needed.

---

## Summary Table: Automated vs Manual

| Step | Mostly automated in platform | Mostly manual |
|------|-----------------------------|--------------|
| **1. Define entity** | Create company, products, services, project. | Choose optimizable type; write entity block. |
| **2. Baseline** | Entity probe, recall, scans, GEO Score, PDF report. | Interpret gaps and plan fixes. |
| **3. Entity & answer content** | Sync description; publish generated definitions/FAQs. | Finalize entity block; add/edit answer-first content strategy. |
| **4. Authority** | Wikis (create/sync/publish), content generation, citations, campaigns, publish to GitHub/Medium/blog. | Link building, PR, Wikipedia, earned media. |
| **5. Distribution** | Configure integrations; publish generated content; sync where API allows. | Align third-party profiles (G2, Capterra, etc.); community/Q&A. |
| **6. Reinforce & monitor** | Repeat entity in generated content; run scans; show GEO Score over time. | Run monitoring prompts in LLMs; tune narratives and prompts. |

---

## Suggested Client Journey (Phases)

**Phase 1 – Setup & baseline (Week 1)**  
Steps 1–2: Define entity in platform, run first scan, review GEO Score and entity snapshot. Deliverable: baseline report + gap list.

**Phase 2 – Entity & content (Weeks 2–3)**  
Step 3: Lock entity block; add definitions/FAQs on site or via platform-generated content. Step 4 (start): Create wikis and first content/campaigns. Deliverable: Entity block live; first wiki/content live.

**Phase 3 – Authority & distribution (Weeks 4–6)**  
Steps 4–5: Scale wikis and content; configure and use integrations; align key third-party profiles (manual where needed). Deliverable: Same message on owned + key external channels.

**Phase 4 – Monitor & iterate (Ongoing)**  
Step 6: Re-scan regularly; run monitoring prompts; tune narratives and prompts. Deliverable: GEO Score and recall improving; client cited correctly in LLMs.

---

## References

- **GEO_PLAN.md** — GEO strategy for thevis’s own brand; same layers (entity, answer architecture, authority, distribution, monitoring) apply to clients.
- **GEO_PLATFORM_OVERVIEW.md** — How the platform works (scans, GEO Score, wikis, content, campaigns).
- **EXTERNAL_SERVICES_GEO.md** — Integrations and external channels (GitHub, Medium, G2, Crunchbase, etc.).
- **PRD.md** — Product vision, users, and features (playbooks, campaigns, wiki automation).
