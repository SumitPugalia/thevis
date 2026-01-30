# External Services to Get Closer to Your GEO Goal

This document lists **external services** (beyond what you already use) that can help thevis get companies and products **ranked and answered by LLMs**. Each is grouped by GEO lever and includes how it helps and how it could integrate.

**You already use:** GitHub, Medium, Blog (WordPress/Contentful), NewsAPI.org, OpenAI.

---

## 1. Earned media & press (authority, citations)

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **PR Newswire / Business Wire / GlobeNewswire** | Distribute press releases to news outlets; high-authority, citable links. | API or RSS: submit releases, track pickups; measure “cited in news” in authority score. |
| **Cision / Meltwater** | Media database, press release distribution, media monitoring. | API: distribute releases, pull “mentions” for citation coverage and recall impact. |
| **HARO (Help A Reporter Out)** | Connect with journalists; get quoted in articles (earned media). | Manual or email integration: surface opportunities; track when client is quoted. |
| **Prowly / Prezly** | PR and newsroom management, press release distribution. | API: publish releases, sync “news” to authority graph and citation tracking. |

**Why it helps:** GEO research shows AI favors **earned media**. More third-party press = more citable sources = better recall and first-mention rank.

---

## 2. Review & social proof (authority, trust signals)

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **G2** | B2B software reviews; often cited by AI for “best X software”. | G2 API or scraping (ToS): ensure profile complete; sync description/claims; track review count as authority signal. |
| **Capterra / GetApp (Gartner Digital Markets)** | Software directories and reviews. | API (if available): profile data, review snippets; feed into authority score and consistency checks. |
| **Trustpilot** | Consumer/brand reviews. | API: sync reviews, aggregate rating; use in narratives and authority dashboard. |
| **Google Business Profile API** | Local/business listing, reviews, Q&A. | API: keep NAP + description consistent; track reviews; measure “mentioned on Google” in authority. |
| **Yelp Fusion API** | Business listings and reviews. | API: profile completeness, review count; authority and consistency. |

**Why it helps:** Review platforms are **high-trust, third-party** sources. Complete profiles + positive reviews improve authority and the chance LLMs cite you.

---

## 3. Directories & business listings (discoverability, citations)

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **Crunchbase** | Company/founder data; often used by AI for company summaries. | API: keep company/product data in sync; track “cited on Crunchbase” in authority. |
| **LinkedIn Company API** | Company page, description, updates. | API: sync narrative to company description; post updates; authority + consistency. |
| **Clutch / GoodFirms** | B2B agency/service directories and reviews. | Profile sync, review tracking; authority for service-based companies. |
| **Product Hunt** | Product launches and upvotes. | API: launch tracking, “mentioned on Product Hunt”; strong signal for product-based GEO. |
| **AlternativeTo / SaaSHub** | Software alternatives and listings. | Ensure listing exists and is accurate; track as citation source. |

**Why it helps:** Directories are **structured, machine-friendly** sources. Consistent listings = more places for LLMs to discover and cite you.

---

## 4. Social & professional (authority, consistency)

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **Twitter / X API** | Tweets, profile, bio. | API: sync bio/description; optional auto-post key updates; consistency + “social proof” in authority. |
| **LinkedIn** (see above) | Company page, posts. | Same as directories; also “posted on LinkedIn” as citation. |
| **Facebook Graph API** | Business page, about, posts. | Sync about text; optional posts; consistency across platforms. |

**Why it helps:** Social profiles are **crawlable**. Consistent messaging (narrative) across them supports consistency scans and reinforces one “canonical” story for LLMs.

---

## 5. Community & Q&A (earned mentions, long-tail queries)

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **Reddit API** | Subreddits, posts, comments. | Monitor mentions; optional “suggest answers” for consultants; track “mentioned on Reddit” in authority. |
| **Stack Overflow / Stack Exchange API** | Q&A (e.g. dev tools). | Track questions where product is recommended; citation source for developer-focused GEO. |
| **Quora** | Q&A, often surfaced in AI answers. | Monitor “best X” questions; ensure product/company appears in high-quality answers (manual or partnership). |
| **Hacker News** | Tech community; launches and discussions. | Track “mentioned on HN”; strong signal for dev/SaaS; optional submit for launches. |

**Why it helps:** Community and Q&A are **earned, third-party** and match how people ask questions. Being recommended there improves recall for those phrasings.

---

## 6. PR & distribution (reach, citations)

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **Press release distribution** (e.g. PR Newswire, EIN Presswire) | Get releases onto many news sites. | Submit from campaigns; track URLs; count as citation sources in authority. |
| **Outreach / Apollo / Hunter** | Find journalists and contacts for guest posts / PR. | Support “authority building” campaigns; track outreach → placement → citation. |
| **Contently / ClearVoice** | Content and guest-post placement. | Place narrative-driven articles on third-party sites; measure as earned media. |

**Why it helps:** More **distributed, third-party** content = more citable URLs = better GEO.

---

## 7. Monitoring & citation tracking (measurement)

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **Mention / Brand24 / Meltwater** | Brand mentions across web and social. | API: “where is the product/company mentioned”; feed into authority graph and citation coverage. |
| **Google Alerts (RSS) / Talkwalker** | Mention alerts. | RSS or API: aggregate “new citations”; dashboard “citation coverage over time”. |
| **Semrush / Ahrefs** | Backlinks, referring domains, content. | API: backlink list = citation sources; track “authority domains that cite us”. |

**Why it helps:** You need to **measure** citation coverage and authority. These services feed “where we’re cited” into your GEO metrics and reports.

---

## 8. Structured data & knowledge (machine scannability)

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **Schema.org / JSON-LD** | Structured data on client site (Organization, Product). | Generate and validate Organization/Product markup from narratives; optional “publish to client site” or guide. |
| **Google Knowledge Panel** | Entity box in search; often used by AI. | No direct API; guide clients on consistency (Wikipedia, official site, GMB) to improve panel; track “panel exists” as KPI. |
| **Wikidata** | Structured knowledge graph; used by many AI systems. | API: create/update entity (company/product); add claims and sources; high-impact for “machine scannability”. |

**Why it helps:** GEO favors **structured, citable** content. Schema and Wikidata make it easier for LLMs to parse and attribute.

---

## 9. Multi-engine & recall (measurement, optimization)

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **Anthropic (Claude) API** | Second major LLM. | Add adapter; run recall/entity-probe on Claude; “recall by engine” (OpenAI vs Claude). |
| **Google AI (Gemini) API** | Another major model. | Same: recall and entity-probe; compare phrasing sensitivity. |
| **Perplexity API** (if/when available) | Search-oriented model. | Recall tests against Perplexity-style answers; tune for “search-like” behavior. |
| **SerpAPI / DataForSEO** | Search result and “AI answer” snapshots. | Check if client appears in real AI overviews (e.g. Google SGE); validate recall in production. |

**Why it helps:** GEO is **engine-specific**. Multi-engine recall and real-search checks get you closer to “ranked and answered” in the wild.

---

## 10. Wikipedia & high-authority wikis

| Service | What it does for GEO | Integration idea |
|--------|------------------------|------------------|
| **Wikipedia / MediaWiki API** | Create/edit articles (with notability and policy). | Draft creation from narratives; citation-backed; track “Wikipedia article exists/updated” in authority. |
| **Wikidata API** | (See structured data above.) | Entity creation/updates; link to Wikipedia; strong training signal. |
| **Industry wikis** (e.g. company-specific, Fandom) | Niche authority. | Ensure client/product has a page; sync key facts; track as citation source. |

**Why it helps:** Wikipedia and Wikidata are among the **highest-authority** sources for LLMs. Presence there strongly supports recall and first-mention rank.

---

## Suggested priority (for your goal)

1. **High impact, clear GEO link**  
   - **Wikidata** (structured + high authority)  
   - **G2 / Capterra / Trustpilot** (reviews = authority)  
   - **PR / press distribution** (earned media)  
   - **Mention / Brand24** (citation tracking)

2. **Multi-engine recall**  
   - **Anthropic + Google AI** adapters and recall runs

3. **Consistency & distribution**  
   - **LinkedIn Company**, **Google Business Profile**, **Crunchbase** (sync narrative, one source of truth)

4. **Community & long-tail**  
   - **Reddit**, **Stack Overflow**, **Product Hunt** (monitor + optional participation)

5. **Structured data**  
   - **Schema.org** generator from narratives; **Wikidata** entity management

Adding these (even incrementally) will strengthen **earned media**, **authority**, **citation coverage**, and **machine-scannable presence**, so you get closer to having companies and products **ranked and answered by LLMs**.

---

## Platform settings JSON keys (consultant UI)

When adding a platform in **Admin → Platform Settings**, use these keys in the settings JSON:

| Platform | Settings keys (JSON) | Env / config |
|----------|----------------------|---------------|
| **Trustpilot** | `business_unit_id` or `domain` | TRUSTPILOT_API_KEY |
| **Yelp** | `business_id` | YELP_API_KEY |
| **Google Business** | `location_name` or `account_id` + `location_id` | GOOGLE_BUSINESS_ACCESS_TOKEN |
| **G2** | `product_slug` or `company_name` | — |
| **Capterra** | `product_slug` or `company_name` | — |
| **Crunchbase** | `entity_id` or `permalink` | CRUNCHBASE_API_KEY |
| **LinkedIn Company** | `company_id` or `vanity_name` | LINKEDIN_ACCESS_TOKEN |
| **Product Hunt** | `slug` | PRODUCT_HUNT_TOKEN |
| **Clutch** | `profile_url` or `company_slug` | — |
| **AlternativeTo** | `product_slug` or `product_name` | — |
| **Twitter / X** | `username` | TWITTER_BEARER_TOKEN |
| **Facebook** | `page_id` or `page_username` | FACEBOOK_ACCESS_TOKEN |
| **Reddit** | `subreddit` or `username` | REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET |
| **Stack Overflow** | `site` (e.g. "stackoverflow"), optional `user_id` | STACK_EXCHANGE_KEY (optional) |
| **Quora** | `profile_url`, `username`, or `space` | — |
| **Hacker News** | `username` or `item_id` | — |
