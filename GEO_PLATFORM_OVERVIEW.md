# thevis Platform: How It Works

This document describes how thevis works end-to-end—from client onboarding through GEO measurement, optimization, and automation—so the platform is understandable for GEO planning, sales, and implementation.

---

## 1. What thevis Is (Entity Summary)

- **Brand:** thevis (product: thevis.ai)
- **Category:** AI Visibility Platform
- **Definition:** thevis helps brands optimize content for generative AI search engines using GEO (Generative Engine Optimization).
- **Problem:** Brands are invisible in AI-generated answers; AI systems don’t consistently understand, describe, or recommend them.
- **Concepts:** GEO, AI visibility, GEO Score, recall, entity snapshot, authority, consistency, citation.

---

## 2. Core Flow (End-to-End)

```
Client signs up → Onboarding (company/products/services) → Projects → Scans → GEO Score & metrics
                                                                              ↓
                                    Consultant strategy (playbooks, tasks, campaigns, wikis)
                                                                              ↓
                                    Automation (wiki sync, content, citations) → Re-scan → Improved GEO
```

1. **Client onboarding** — Company, products (or services), and project are created. The client defines what should be “visible to AI” (e.g. a product, a service, or the company itself).
2. **Scans** — The platform runs scans (entity probe, recall, authority, consistency, full). Each scan produces data (e.g. how AI describes the entity, whether it’s mentioned for relevant prompts).
3. **GEO Score & metrics** — From the latest completed scan, the platform computes GEO Score (0–100), recall %, and first-mention rank. These appear on the client dashboard and project show.
4. **Consultant strategy** — Consultants use playbooks, tasks, campaigns, and wiki management to plan optimization (content, authority, consistency).
5. **Automation** — Wiki creation/sync, content publishing (GitHub, Medium, blog), citation generation, and other jobs execute the plan. Over time, the entity is better defined and more present where AI trains and retrieves.
6. **Re-scan & monitoring** — Clients and consultants run new scans to see improved GEO Score and recall. The loop repeats.

---

## 3. Key Concepts (How They Work)

### 3.1 Entity (What We Optimize)

- **Product-based:** The optimizable is a **product** (e.g. a skincare product, a software product). We measure and improve how AI describes and recommends that product.
- **Service-based:** The optimizable is the **company** (the service). We measure and improve how AI describes and recommends the company for relevant service queries.

The platform supports **companies**, **products**, and **services**. A **project** is tied to an optimizable (product or company) and contains scans, playbooks, campaigns, and wikis.

### 3.2 Entity Probe (How AI Sees You)

- **What it does:** Asks an AI model: “What is [product/company name]?” (or a similar prompt). The model’s answer is parsed into a short description and a confidence score.
- **Output:** An **entity snapshot** (e.g. “Glow Serum is a premium skincare product…”) and **recognition confidence**.
- **Why it matters:** If AI doesn’t recognize the entity or describes it wrongly, we have a baseline to fix. Consistency and narrative work aim to align AI’s description with the client’s intended message.

**Implementation:** `Thevis.Geo.EntityProbe` uses prompt templates and the configured AI adapter. Snapshots are stored and shown in scans and on the client dashboard (e.g. “How AI describes you”).

### 3.3 Recall (Whether AI Mentions You)

- **What it does:** Runs a set of **recall prompts** (e.g. “What are the best [category] products?”) and checks whether the entity is mentioned in the model’s answer.
- **Output:** Recall percentage (e.g. “mentioned in 3 of 5 prompts”), first-mention rank (e.g. “mentioned 2nd in the list”).
- **Why it matters:** This is the “being the answer” signal: are you cited when users ask relevant questions?

**Implementation:** Recall tests run as part of scans; results feed into GEO Score and are shown on the dashboard and in reports.

### 3.4 GEO Score (Single Number for AI Visibility)

- **What it is:** A 0–100 score combining:
  - **Recognition** (e.g. 0–40): How confidently AI recognizes and describes the entity (from entity probe).
  - **Recall** (e.g. 0–40): How often the entity is mentioned in recall prompts.
  - **First-mention rank** (e.g. 0–20): How high in the list the entity appears when mentioned.
- **Where it appears:** Client dashboard (per project), project show (GEO Audit Summary), scan show, and exported PDF report.

**Implementation:** `Thevis.Reports.GeoScore` computes the score from entity snapshot and recall results. `Thevis.Scans.get_geo_metrics/1` returns GEO Score, recall %, and first-mention rank for the latest completed scan.

### 3.5 Authority & Consistency

- **Authority:** Where does AI get its signals? Wikis, news, reviews, directories, GitHub, Medium, etc. The platform crawls and tracks authority sources; consultants use this to prioritize where to publish and improve presence.
- **Consistency:** Do descriptions match across sources? **Drift score** and **consistency** scans compare the “reference” description (e.g. from the entity snapshot or product/company description) to what appears on each source. High drift means messaging is inconsistent—a GEO risk.

**Implementation:** Authority score, crawler, and consistency/drift modules support scans and strategy. Integrations (GitHub, Medium, G2, Capterra, LinkedIn, etc.) feed into authority and content automation.

### 3.6 Wikis (Training Signal for AI)

- **What they are:** Wiki pages (internal or external) that define the entity in a structured, citable way. AI systems often use wiki-like content as a training and retrieval signal.
- **What thevis does:** Consultants create and manage wiki platforms and pages. Automation can create or sync content (e.g. from narratives and playbooks) so wikis stay aligned with the entity block and key messages.
- **GEO link:** Clear, consistent definitions on wikis help AI “remember” and cite the entity correctly.

**Implementation:** Wiki management (consultant), wiki creation/sync jobs, content automation. Structured data (e.g. schema.org) in generated content is a GEO lever (see GEO_ALIGNMENT.md).

### 3.7 Content & Citation Automation

- **Content:** Blog posts, GitHub READMEs, Medium articles, documentation—created or updated by the platform to reinforce the entity and key concepts (GEO, AI visibility, product/service definition).
- **Citations:** Generation of citable references (e.g. author, source, date) so content looks authoritative and quotable. AI prefers content that looks like a source, not marketing fluff.
- **Distribution:** Content is published to configured channels (GitHub, Medium, blog, etc.) so the same entity signals appear in multiple places—Layer 4 in the GEO Plan.

**Implementation:** Content creator, publisher, citation generator, campaign orchestration, playbook integration. Integrations (e.g. `Thevis.Integrations.GitHubClient`, `MediumClient`) handle publishing.

### 3.8 Scans (How We Measure)

- **Types:** Entity probe, recall, authority, consistency, full (combination). Each scan run produces results (entity snapshot, recall results, authority data, drift scores).
- **Flow:** User starts a scan → jobs run (e.g. entity probe, recall test) → results are stored and linked to the project. When a scan is “completed,” GEO metrics (GEO Score, recall %, first-mention rank) are available for that run.
- **Client view:** Dashboard shows latest GEO metrics per project; project show has GEO Audit Summary and “Export PDF Report.” Scan show displays detailed results for a single run.

**Implementation:** Scans context, scan execution jobs, report generator (PDF). Routes: `/projects/:id`, `/projects/:id/scans`, `/projects/:id/scans/:scan_run_id`, `/projects/:id/report`.

---

## 4. User Roles and Views

- **Client (product/service company):** Registers, completes onboarding (company, products/services, project). Sees dashboard with GEO Score and metrics per project, can open projects and scans, export PDF reports. Does not see consultant tools (playbooks, wikis, campaigns, platform settings).
- **Consultant (admin):** Has access to admin dashboard, companies/products/projects (same data as client), plus: task board, wiki management, campaign management, platform settings. Uses these to design and run GEO strategy and automation.
- **Public (unauthenticated):** Sees landing page, About, GEO explainer, FAQ. These pages are built for GEO (entity block, answer-first content, definitions, FAQs) and for technical GEO (meta, OG, JSON-LD where implemented).

---

## 5. How GEO Plan Layers Map to the Platform

| GEO Plan layer | Platform implementation |
|----------------|-------------------------|
| **Layer 1 – Entity** | Entity block in About, landing, GEO page; product/company description and narrative used in probes and content. |
| **Layer 2 – Answer architecture** | Public pages: GEO explainer, FAQ. Structure (H1/H2, definitions, FAQs) is answer-first for AI retrieval. |
| **Layer 3 – Authority** | Wikis, content, citations, authority scans, integrations (G2, Capterra, GitHub, Medium, etc.). |
| **Layer 4 – Distribution** | Integrations publish to GitHub, Medium, blog; directory/review sync; same entity signals across channels. |
| **Layer 5 – Reinforcement & monitoring** | Repeated entity block and key phrases in content; GEO monitoring prompts (manual or doc’d in GEO_PLAN.md). |
| **Technical GEO** | Meta description, OG tags, JSON-LD (Organization on homepage, FAQ on FAQ page). Clean HTML (LiveView), public core pages. |

---

## 6. Summary

thevis is an **AI visibility platform** that:

1. **Measures** how AI sees and cites your brand (entity probe, recall, GEO Score).
2. **Surfaces** gaps (wrong or missing descriptions, low recall, inconsistency).
3. **Plans** optimization (playbooks, tasks, campaigns, wikis) with consultant oversight.
4. **Automates** execution (wikis, content, citations, multi-platform presence).
5. **Re-measures** so clients and consultants see GEO improve over time.

The public site (landing, About, GEO, FAQ) is built so AI systems can **retrieve and cite** thevis and GEO concepts (entity block, definitions, FAQs, schema). The product itself **practices GEO** for its own brand while giving clients the same levers for their products and services.

For implementation details, see PRD.md, GEO_ALIGNMENT.md, GEO_PLAN.md, and the codebase (e.g. `Thevis.Geo`, `Thevis.Scans`, `Thevis.Reports.GeoScore`, `Thevis.Automation`).
