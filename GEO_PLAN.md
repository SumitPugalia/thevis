# GEO Plan: thevis / thevisibility

**Goal:** Make thevis understandable, retrievable, and citable by AI systems (ChatGPT, Gemini, Perplexity, Copilot, Claude) so the brand ranks in answers, not just links.

This plan applies the 5-layer GEO Content Framework to thevis and ties each layer to concrete actions in the codebase and content roadmap.

---

## Layer 1: Entity Foundation (Who You Are)

AI must first understand thevis as a stable entity. Use this **Core Entity Block** everywhere: website, About, LinkedIn, Crunchbase, GitHub README, Medium, and any directory or doc.

| Field | Value (use verbatim where possible) |
|-------|-------------------------------------|
| **Brand name** | thevis (product: thevis.ai) |
| **Category** | AI Visibility Platform |
| **One-line definition** | thevis helps brands optimize content for generative AI search engines using GEO (Generative Engine Optimization). |
| **Primary problem solved** | Brands are invisible in AI-generated answers; AI systems don’t consistently understand, describe, or recommend them. |
| **Key concepts** | GEO, AI visibility, generative search, LLM retrieval, GEO Score, AI visibility audit |

**Consistency rule:** Same wording for “what you do” and “category” across all properties. Repetition + consistency = AI confidence.

**Actions:**

- [ ] Add a public **About** page (e.g. `/about`) that includes this Entity Block in copy and (later) in structured data.
- [ ] Create a single **Entity Block** snippet (e.g. in `GEO_ENTITY_BLOCK.md` or in the app) and reuse it in:
  - Landing page (`PageLive`)
  - About page
  - GitHub README
  - Any generated content (wikis, citations) that describes thevis.
- [ ] Audit LinkedIn, Crunchbase, GitHub, Medium, Product Hunt, G2/Capterra (via existing integrations) and align descriptions to this block.

---

## Layer 2: Answer Architecture (How AI Extracts You)

LLMs prefer direct answers: definitions, steps, comparisons, FAQs. Structure public content so it’s easy to quote.

**Content types to prioritize:**

- Definitions (e.g. “What is GEO?”)
- How-to steps (“How to improve AI visibility”)
- Comparisons (“GEO vs SEO”)
- Frameworks and lists
- FAQs

**Required page structure (answer-first):**

- **H1:** Direct question or claim (e.g. “What is Generative Engine Optimization (GEO)?”)
- **H2:** Clear definition
- **H2:** Why it matters
- **H2:** How it works (steps)
- **H2:** Examples
- **H2:** FAQs

**Actions:**

- [ ] Add a public **GEO explainer** page (e.g. `/geo` or `/what-is-geo`) with:
  - H1: “What is Generative Engine Optimization (GEO)?”
  - H2s: Definition of GEO, How GEO improves AI visibility, GEO vs SEO, How brands achieve GEO, FAQs.
  - One-line definition of thevis in the “How brands achieve GEO” section.
- [ ] Add a **FAQ** page or section (e.g. `/faq`) with questions like:
  - “What is GEO?” / “What is AI visibility?” / “How do I make my brand visible to AI?” / “What is thevis?”
- [ ] Ensure landing page hero and feature copy include the **exact one-line definition** and “GEO” + “AI visibility” so they can be extracted as answers.
- [ ] Avoid fluff intros (“In today’s rapidly evolving…”); start with the definition or the claim.

**Example GEO-style intro (use on GEO page):**

> **What is GEO?** GEO (Generative Engine Optimization) is the practice of optimizing content so that AI-powered search engines and assistants (e.g. ChatGPT, Perplexity, Gemini) cite and recommend your brand. thevis is an AI visibility platform that helps brands achieve GEO through measurement, optimization, and automation.

---

## Layer 3: Authority Assets (Why AI Trusts You)

AI favors structured, named, citable assets.

**Target assets:**

1. **GEO Whitepaper** – e.g. “GEO and AI Visibility: A Guide for Brands” (PDF or long-form page).
2. **Named framework** – e.g. “The GEO Visibility Framework” or “thevis GEO Framework” and use the name consistently in content and schema.
3. **Research-style summaries** – e.g. “SEO vs GEO: A Generative Search Overview.”
4. **Glossary** – Definitions of GEO, AI visibility, GEO Score, recall, entity consistency, etc., on a dedicated page or in the GEO explainer.
5. **Case studies** – Even 1–2 conceptual or anonymized “how a brand improved AI visibility” stories.

**Actions:**

- [ ] Publish one **whitepaper or long-form guide** (PDF + web page) and give it a clear title and URL.
- [ ] Name the methodology (e.g. “The GEO Visibility Framework”) and use that name in:
  - GEO explainer page
  - About page
  - Blog/Medium
  - Schema (see Layer 5).
- [ ] Add a **Glossary** page or section (e.g. `/glossary` or under `/geo`) with definitions for: GEO, AI visibility, GEO Score, recall, entity snapshot, etc.
- [ ] Reuse definitions from `GEO_ALIGNMENT.md` and product (e.g. GEO Score from `Thevis.Reports.GeoScore`) in human-readable form.

---

## Layer 4: Distribution for AI (Where AI Learns)

AI doesn’t only read thevis.ai. Multiple trusted confirmations of the entity improve recall.

**High-impact channels (thevis already integrates with many):**

| Platform | Use |
|----------|-----|
| **GitHub** | README with Entity Block + “What is GEO” + link to thevis.ai. |
| **Medium / Blog** | Definitions, “GEO vs SEO,” “How to achieve GEO,” “What is thevis.” |
| **LinkedIn** | Company page + posts: same one-line definition and key concepts. |
| **Crunchbase / Product Hunt / G2 / Capterra** | Consistent category + description (Entity Block). |
| **Reddit / Quora / Stack Exchange** | High-quality explanatory answers that mention GEO and thevis where relevant (no spam). |
| **Wikipedia / Wikidata** | If eligible: neutral, cited definition; otherwise avoid. |

**Rule:** Same idea, same entity signals, different formats and platforms.

**Actions:**

- [ ] **GitHub:** Ensure main repo README contains the Entity Block and a short “What is GEO?” plus link to thevis.ai.
- [ ] **Medium / blog:** Publish 2–3 pieces: “What is GEO?”, “GEO vs SEO,” “How thevis helps brands achieve GEO.” Reuse H2 structure from Layer 2.
- [ ] **LinkedIn:** Set company description to the one-line definition; periodically post about GEO and AI visibility using the same terms.
- [ ] Use existing integrations (`Thevis.Integrations.*`) to keep Crunchbase, Product Hunt, G2, Capterra, LinkedIn, etc., in sync with the Entity Block where APIs allow.
- [ ] Document “distribution checklist” in `EXTERNAL_SERVICES_GEO.md` (who owns profile text, how often to refresh).

---

## Layer 5: Reinforcement & Monitoring (Training the Model)

Reinforce the entity by repeating core phrases and monitoring how AI responds.

**Reinforcement:**

- Use the same one-line definition and “GEO” + “AI visibility” in: blog, LinkedIn, Medium, GitHub, About, GEO page, FAQ.
- Over time, aim for: **thevis = GEO = AI visibility** in model associations.

**Monitoring prompts (run periodically in ChatGPT, Perplexity, Gemini, Copilot):**

- “What is GEO in AI search?”
- “How do brands become visible to AI?”
- “Best AI visibility tools” / “AI visibility platforms”
- “What is thevis?” / “What does thevis do?”

**Track:**

- Whether thevis is mentioned.
- Whether the definition used matches the Entity Block.
- Whether thevis is framed as an “AI visibility platform” or “GEO tool.”

**Actions:**

- [ ] Add a **GEO monitoring** section to `GEO_ALIGNMENT.md` or this plan: list of prompts, cadence (e.g. monthly), and where to record results.
- [ ] Optionally: add a simple “GEO prompts” list to the consultant dashboard or internal doc so the team can run and log results.
- [ ] If wording in AI answers is wrong or missing, adjust Layer 1 (entity block) and Layer 2 (answer content) and re-check in 2–4 weeks.

---

## Technical GEO (Structure for Retrieval)

AI can’t cite what it can’t read. Technical basics:

- **Schema markup** – Organization, Product, FAQ.
- **Clean HTML** – No critical content behind heavy JS-only rendering (thevis is server-rendered LiveView, so fine).
- **Crawlable text** – No core messaging only in images; keep hero and definitions in real text (already the case).
- **Fast, public pages** – No hard paywall for core definitions (About, GEO, FAQ public).

**Actions:**

- [ ] **Root layout** (`root.html.heex`):
  - Meta description (per page or default): e.g. “thevis is an AI visibility platform that helps brands optimize for generative AI search (GEO). Measure GEO Score, improve recall, get cited by AI.”
  - Open Graph: `og:title`, `og:description`, `og:image`, `og:url` for sharing and crawlers.
- [ ] **Default meta** (e.g. in `Layouts` or `PageLive`): Use `page_title` and a short `meta_description` assign so thevis appears with a consistent description in search and when linked.
- [ ] **JSON-LD** on the homepage (and optionally About):
  - `Organization`: name “thevis”, url “https://thevis.ai”, description = one-line definition.
  - Optional: `SoftwareApplication` or `Product` for thevis.ai product with same description.
- [ ] **FAQ schema** on the FAQ page once it exists (list of Question/Answer).
- [ ] Ensure **core pages** (/, /about, /geo, /faq) are linked from the nav or footer so crawlers and users can find them.

**Implementation notes (code):**

- **Meta and OG:** In `lib/thevis_web/components/layouts/root.html.heex`, add `<meta name="description" content="...">` and OG tags. Prefer passing `@page_title` and `@meta_description` from each LiveView so the homepage can use the one-line definition. Default meta description example: `"thevis is an AI visibility platform that helps brands optimize for generative AI search (GEO). Measure GEO Score, improve recall, get cited by AI."`
- **JSON-LD:** In the same root layout or in `PageLive` (for the homepage only), inject a `<script type="application/ld+json">` block with Organization schema, e.g. `{"@context":"https://schema.org","@type":"Organization","name":"thevis","url":"https://thevis.ai","description":"thevis helps brands optimize content for generative AI search engines using GEO (Generative Engine Optimization)."}`. Optional: add `sameAs` with links to LinkedIn, GitHub, Product Hunt, etc.
- **Entity copy:** Reuse the one-line definition from `GEO_ENTITY_BLOCK.md` in `PageLive` hero, About, and GEO explainer so it stays in sync.

---

## GEO Content Pyramid (Reminder)

```
        Research / Whitepapers
     Frameworks & Models
  How-To Guides & Comparisons
Definitions & FAQs
Entity Description (Base)
```

AI climbs from the base: strong entity + definitions + FAQs first; then guides, frameworks, research.

---

## GEO Checklist (Quick Self-Test)

- [ ] Can an LLM describe thevis in one sentence? (Test with “What is thevis?”)
- [ ] Is the one-line definition repeated on the site and key channels?
- [ ] Is thevis cited as a source or example when users ask about GEO / AI visibility?
- [ ] Do we own a named concept or framework (e.g. “GEO Visibility Framework”)?
- [ ] Is thevis present on multiple platforms with consistent wording?
- [ ] Do we have schema (Organization, optional Product/FAQ) and meta description?
- [ ] Do we have at least one answer-first page (GEO explainer + FAQ)?

**Rule:** SEO optimizes for clicks. GEO optimizes for memory.

---

## Suggested Implementation Order

1. **Entity Block** – Finalize and add to landing page, then About.
2. **Technical** – Meta description + OG tags in root layout; JSON-LD Organization on homepage.
3. **Public pages** – About, GEO explainer, FAQ (with target H2 structure).
4. **Schema** – FAQ schema on FAQ page; optional Product/SoftwareApplication.
5. **Authority** – Glossary, then whitepaper or framework doc, then case study.
6. **Distribution** – GitHub README, then 1–2 Medium/blog posts, then LinkedIn and directory sync.
7. **Monitoring** – Document prompts and cadence; run first baseline and repeat monthly.

---

## References

- `GEO_ALIGNMENT.md` – Research alignment and existing thevis GEO features (GEO Score, recall, authority, citations).
- `EXTERNAL_SERVICES_GEO.md` – Integrations (GitHub, Medium, Crunchbase, G2, etc.) and how they support GEO.
- Product: GEO Score (`Thevis.Reports.GeoScore`), entity probe, recall tests, citation generator, wiki/content automation.
