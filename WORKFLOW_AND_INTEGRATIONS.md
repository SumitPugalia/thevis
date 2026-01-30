# Workflow Status & Integration API Keys

**Purpose:** Single reference for (1) six-step GEO workflow status, (2) verification that integrations are real (not mocked) in dev/prod, and (3) every env var / API key / token you need to provide.

---

## Part 1: Six-step workflow – what’s done vs pending

| Step | Goal | Status | Notes |
|------|------|--------|--------|
| **1. Define entity** | Company, products, project, entity block | ✅ Done | CRUD + “Suggest with AI” for entity block on admin company edit. Choose optimizable type remains manual. |
| **2. Baseline** | Entity probe + recall, GEO Score, report | ✅ Done | Full scan (entity_probe, recall, authority, consistency). Auto-triggered on project create; recurring via `/admin/scheduled-tasks`. |
| **3. Entity & answer content** | Sync description, generate/publish content | ✅ Done | Edit company/product; narratives/playbooks; content generation + publish to GitHub/Medium/blog. |
| **4. Authority** | Wikis, content, citations, campaigns | ✅ Done | Wiki jobs, campaign orchestrator, content publishing. Link building / PR / Wikipedia remain manual. |
| **5. Distribution** | Integrations, publish, sync profiles | ✅ Done | Platform Settings store config; publish to channels; sync where API allows. Third-party profile alignment mostly manual. |
| **6. Reinforce & monitor** | Recurring scans, GEO over time | ⚠️ One gap | Recurring scans ✅ (scheduled tasks). **Pending:** “Monitoring prompts” job (run fixed prompts via AI, store mentions/rank). Schedule type `monitoring_prompts` exists; job not implemented. |

**Pending (optional):**

- **Step 6 – Monitoring prompts:** Oban job that, for each active project, runs 2–3 fixed prompts (e.g. “Best [category] products?”) via the AI adapter, stores whether the client is mentioned and at what rank, and a “Monitoring” / LLM mentions view. Documented in `GEO_AUTOMATION_PIPELINE.md` Phase B.
- **Phase C (optional):** Default campaign on project create; gap-suggestions job after scan.

Everything else in the 6 steps is implemented and automated where designed (manual actions stay manual by design).

---

## Part 2: Integrations – real vs mocked

**All integrations are real in dev and prod.** They use:

- **HTTP:** `Thevis.HTTP` (Req-based) for real outbound calls.
- **AI:** `Thevis.AI` with `Thevis.AI.OpenAIAdapter` in dev/prod (real OpenAI).

**Only in test:**

- **AI** is switched to `Thevis.AI.MockAdapter` via `config/test.exs` so tests don’t call OpenAI.
- Integrations still use real `Thevis.HTTP` in tests; external calls are either not triggered or go to test servers (e.g. Bypass) where tests set that up.

No integration code in `lib/thevis` is “mock-only”; the only mock is the AI adapter in test.

---

## Part 3: API keys, tokens, and env vars (checklist)

Set these in your environment (e.g. `.env` or host env). Config reads them via `System.get_env/1` (or `System.get_env/2` with defaults where noted).

### Core (required for GEO / scans / entity block)

| Env var | Used by | Purpose |
|--------|---------|--------|
| `OPENAI_API_KEY` | Thevis.AI (OpenAI adapter) | Entity probe, recall test, entity block suggestions, embeddings, content generation. |

### Content publishing (Steps 3–4)

| Env var | Used by | Purpose |
|--------|---------|--------|
| `GITHUB_API_TOKEN` | Thevis.Integrations.GitHub | Publish README/content to GitHub repos. |
| `MEDIUM_API_TOKEN` | Thevis.Integrations.Medium | Publish articles to Medium. |
| `BLOG_CMS_TYPE` | Thevis.Integrations.Blog | Default `wordpress`; or `contentful`. |
| `BLOG_API_URL` | Thevis.Integrations.Blog | Blog/CMS API base URL. |
| `BLOG_API_KEY` | Thevis.Integrations.Blog | API key for blog/CMS. |
| `BLOG_USERNAME` | Thevis.Integrations.Blog | Username for blog auth if needed. |
| `CONTENTFUL_SPACE_ID` | Thevis.Integrations.Blog | Only if `BLOG_CMS_TYPE=contentful`. |
| `CONTENTFUL_ENVIRONMENT_ID` | Thevis.Integrations.Blog | Default `master`; only for Contentful. |
| `CONTENTFUL_CONTENT_TYPE_ID` | Thevis.Integrations.Blog | Default `blogPost`; only for Contentful. |
| `CONTENTFUL_LOCALE` | Thevis.Integrations.Blog | Default `en-US`; only for Contentful. |

### News / crawl (optional)

| Env var | Used by | Purpose |
|--------|---------|--------|
| `NEWS_API_KEY` | Thevis.Integrations.NewsApiClient | Crawl news (e.g. for consistency/authority). |

### Review / directory / social (per integration you enable)

| Env var | Used by | Purpose |
|--------|---------|--------|
| `TRUSTPILOT_API_KEY` | Thevis.Integrations.TrustpilotClient | Trustpilot API. |
| `YELP_API_KEY` | Thevis.Integrations.YelpClient | Yelp API. |
| `GOOGLE_BUSINESS_ACCESS_TOKEN` | Thevis.Integrations.GoogleBusinessClient | Google Business Profile. |
| `CRUNCHBASE_API_KEY` | Thevis.Integrations.CrunchbaseClient | Crunchbase. |
| `LINKEDIN_ACCESS_TOKEN` | Thevis.Integrations.LinkedInCompanyClient | LinkedIn company profile. |
| `PRODUCT_HUNT_TOKEN` | Thevis.Integrations.ProductHuntClient | Product Hunt (api_token). |
| `TWITTER_BEARER_TOKEN` | Thevis.Integrations.TwitterClient | Twitter/X API (Bearer). |
| `FACEBOOK_ACCESS_TOKEN` | Thevis.Integrations.FacebookClient | Facebook Graph API. |
| `REDDIT_CLIENT_ID` | Thevis.Integrations.RedditClient | Reddit API OAuth. |
| `REDDIT_CLIENT_SECRET` | Thevis.Integrations.RedditClient | Reddit API OAuth. |
| `STACK_EXCHANGE_KEY` | Thevis.Integrations.StackExchangeClient | Stack Exchange API (optional but recommended). |

### No API key required (URL/slug or public API)

These use profile URL, slug, or public APIs only; no env vars in `config.exs`:

- **G2** – build profile URL from slug/settings.
- **Capterra** – profile URL/slug.
- **Clutch** – profile URL/slug.
- **AlternativeTo** – profile URL/slug.
- **Quora** – profile URL/slug.
- **Hacker News** – public Firebase API; no key.

---

## Summary table: env vars to provide

| # | Env var | Required for |
|---|---------|----------------|
| 1 | `OPENAI_API_KEY` | AI (entity probe, recall, suggestions, content) |
| 2 | `GITHUB_API_TOKEN` | Publish to GitHub |
| 3 | `MEDIUM_API_TOKEN` | Publish to Medium |
| 4 | `BLOG_API_URL` | Blog/CMS (if using blog publish) |
| 5 | `BLOG_API_KEY` | Blog/CMS |
| 6 | `BLOG_USERNAME` | Blog/CMS (if needed) |
| 7 | `NEWS_API_KEY` | News crawl (optional) |
| 8 | `TRUSTPILOT_API_KEY` | Trustpilot (optional) |
| 9 | `YELP_API_KEY` | Yelp (optional) |
| 10 | `GOOGLE_BUSINESS_ACCESS_TOKEN` | Google Business (optional) |
| 11 | `CRUNCHBASE_API_KEY` | Crunchbase (optional) |
| 12 | `LINKEDIN_ACCESS_TOKEN` | LinkedIn (optional) |
| 13 | `PRODUCT_HUNT_TOKEN` | Product Hunt (optional) |
| 14 | `TWITTER_BEARER_TOKEN` | Twitter (optional) |
| 15 | `FACEBOOK_ACCESS_TOKEN` | Facebook (optional) |
| 16 | `REDDIT_CLIENT_ID` | Reddit (optional) |
| 17 | `REDDIT_CLIENT_SECRET` | Reddit (optional) |
| 18 | `STACK_EXCHANGE_KEY` | Stack Exchange (optional) |

Contentful-only (if `BLOG_CMS_TYPE=contentful`): `CONTENTFUL_SPACE_ID`, `CONTENTFUL_ENVIRONMENT_ID`, `CONTENTFUL_CONTENT_TYPE_ID`, `CONTENTFUL_LOCALE`.

---

**Summary:** All 6 steps are covered; the only missing piece is the **monitoring prompts job** (Step 6). All integrations are real in dev/prod; only the AI adapter is mocked in test. Use the table above to collect the tokens/API keys you need.
