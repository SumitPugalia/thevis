# GEO (Generative Engine Optimization) Alignment

This document aligns thevis with GEO research (e.g. *Generative Engine Optimization: How to Dominate AI Search*) and outlines what the platform does and what more can be done to get companies/products **ranked and answered by LLMs**.

## Research Takeaways

- **GEO vs SEO**: Generative engines synthesize answers from many sources; optimization is about being **cited and represented** in those answers, not just ranking in a list.
- **Earned media bias**: AI systems favor **third‑party, authoritative** sources over brand-owned and social content.
- **Key levers**:
  1. **Content for machine scannability and justification** – structured, citable, easy for models to parse and attribute.
  2. **Dominate earned media** – authority through citations, press, reviews, directories, wikis.
  3. **Engine- and language-aware strategies** – different engines vary in freshness, domain diversity, phrasing sensitivity.
  4. **Overcome big-brand bias** – niche players need targeted authority and consistency.

## What thevis Already Does (PRD → Codebase)

| PRD / GEO lever | Implementation |
|------------------|----------------|
| **GEO Score** (recognition + recall + first mention) | `Thevis.Reports.GeoScore`, `Scans.get_geo_metrics/1`; shown on client dashboard and project show. |
| **Recall measurement** | Recall tests, recall %, first mention rank; scan types `entity_probe`, `recall`, `full`. |
| **Client GEO Audit** | GEO Score, recall %, first mention rank on dashboard; GEO Audit Summary on project show. |
| **Exportable audit report** | PDF report; client route `/projects/:id/report` and Export PDF on dashboard, project show, scan show. |
| **Wiki as training signal** | Wiki platforms, pages, content; wiki creation/sync jobs; consultant Wiki Management. |
| **Authority** | Authority graph, authority score, crawler; authority scan type. |
| **Consistency** | Consistency scan, drift score, vectorizer. |
| **Content automation** | Content creator, publisher, campaigns; GitHub, Medium, blog, wiki. |
| **Citation generation** | `Thevis.Automation.CitationGenerator`. |

## Workflows Completed in This Pass

1. **GEO metrics for clients** – `Scans.get_geo_metrics/1` from latest *completed* scan (GEO score, recall %, first mention rank).
2. **Client dashboard** – GEO Score (0–100), recall %, first mention rank per project when metrics exist; fallback to AI Recognition Confidence when no completed scan.
3. **Client report download** – Authenticated routes `GET /projects/:id/report` and `GET /projects/:id/report/:scan_run_id`; Export PDF on dashboard (per project), project show, and scan show (for completed scans).
4. **Project show** – GEO Audit Summary (GEO Score, Recall %, First Mention Rank) and Export PDF Report when metrics exist.

## What More Can Be Done (GEO + LLM visibility)

1. **Earned media and citations**
   - Strengthen **citation placement** (where and how often the product/company is cited).
   - Track **citation coverage** (news, directories, review sites, wikis) and expose in dashboard.
   - Automate **press/news placement** and **directory/review** updates and measure impact on recall.

2. **Content for machine scannability**
   - **Structured data** (e.g. schema.org, infoboxes) in generated content and wikis.
   - **Explicit “definition” blocks** and key facts in wiki and blog content so LLMs can quote and attribute.
   - **Prompt-aware content**: align narratives and content with common user phrasings (engine/language-aware).

3. **Multi-engine and phrasing**
   - Run recall/entity-probe **per engine** (e.g. OpenAI, Anthropic, Perplexity-style) and report per-engine recall.
   - Test **phrasing variants** in prompts and optimize content for the phrasings that drive mentions.

4. **Authority and “big brand”**
   - **Authority score over time** and breakdown by source type (wiki, news, reviews, etc.).
   - **Competitor displacement** metric (how often we’re mentioned instead of competitors) and tracking.
   - **Niche positioning**: playbooks and narratives tuned for niche vs broad queries.

5. **Historical progress (PRD 5.1.4)**
   - **GEO Score trend** and **recall over time** on client dashboard (charts).
   - **Definition accuracy** over time if ground-truth descriptions are stored.

6. **Service-based companies**
   - Ensure **company-as-service** is the optimized entity (recall tests, narratives, wikis) and that GEO metrics and reports work for service-only projects (no product).

7. **Wikipedia and high-authority wikis**
   - **Wikipedia-compliant** content generation and update flows (notability, NPOV, citations).
   - Track **wiki presence** (which wikis mention the entity) and impact on GEO score/recall.

Implementing the above will move thevis closer to the GEO research goals: **structured, citable content**, **strong earned media**, and **measured visibility across engines and phrasings** so companies and products are consistently **ranked and answered by LLMs**.
