# Technical Implementation Document
## thevis.ai

**Version:** 1.0  
**Date:** 2024  
**Product:** thevis  
**Technology Stack:** Elixir + Phoenix

---

## 1. System Architecture

### 1.1 High-Level Architecture

```
┌─────────────────┐
│  Client UI      │
│  (LiveView)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Phoenix API    │
│  (Contexts)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  GEO Core       │
│  Engines (OTP)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Data Layer     │
│  Postgres +     │
│  Vector Store   │
└─────────────────┘
```

### 1.2 Component Layers

1. **Presentation Layer**: Phoenix LiveView for real-time UI
2. **Application Layer**: Phoenix contexts for business logic
3. **Domain Layer**: OTP-based GEO engines for core functionality
4. **Data Layer**: PostgreSQL for relational data, Vector store for embeddings

---

## 2. Technology Stack

### 2.1 Core Technologies

- **Elixir**: 1.16+
- **Phoenix**: 1.7+ (with LiveView)
- **OTP**: Supervision trees, GenServers, Tasks
- **Ecto**: 3.x for database access

### 2.2 Database

- **PostgreSQL**: 14+ (primary database)
- **pgvector**: Vector similarity search (initial implementation)
- **Alternative**: Qdrant (for production scale)

### 2.3 Background Jobs

- **Oban**: Background job processing
- **Oban Pro**: For advanced scheduling (optional)

### 2.4 AI / LLM Integration

- **OpenAI API**: Primary LLM provider
- **Anthropic API**: Alternative/additional provider
- **Pluggable Adapter Pattern**: Support multiple providers

### 2.5 HTTP Clients

- **Req**: Modern HTTP client for Elixir
- **Tesla**: Alternative (if needed for specific integrations)

### 2.6 Additional Libraries

- **nimble_options**: Configuration validation
- **gen_stage**: Data pipelines (optional)
- **jason**: JSON encoding/decoding
- **phoenix_html**: HTML generation
- **ex_doc**: Documentation generation

---

## 3. Project Structure

### 3.1 Directory Layout

```
lib/thevis/
├── accounts/          # User and company management
│   ├── user.ex
│   ├── company.ex
│   ├── role.ex
│   └── accounts.ex
├── products/          # Product management (what we optimize)
│   ├── product.ex
│   ├── competitor_product.ex
│   └── products.ex
├── projects/          # Project management (tied to products)
│   ├── project.ex
│   └── projects.ex
├── scans/             # Scan execution and results
│   ├── scan_run.ex
│   ├── scan_result.ex
│   └── scans.ex
├── geo/               # GEO Core Engines
│   ├── entity_probe/
│   │   ├── entity_probe.ex
│   │   ├── prompt_templates.ex
│   │   └── entity_parser.ex
│   ├── recall/
│   │   ├── recall_test.ex
│   │   └── recall_scorer.ex
│   ├── authority/
│   │   ├── crawler.ex
│   │   └── authority_graph.ex
│   ├── consistency/
│   │   ├── consistency.ex
│   │   └── vectorizer.ex
│   ├── strategy/      # Internal only
│   │   ├── opportunity_detector.ex
│   │   ├── playbook_selector.ex
│   │   ├── narrative_builder.ex
│   │   └── execution_planner.ex
│   └── automation/    # Automation engines
│       ├── optimizer.ex
│       ├── content_creator.ex
│       ├── publisher.ex
│       ├── authority_builder.ex
│       ├── consistency_manager.ex
│       └── wiki_manager.ex      # Wiki page management (core)
├── ai/                # AI/LLM adapters
│   ├── adapter.ex     # Behaviour
│   ├── openai_adapter.ex
│   └── anthropic_adapter.ex
├── reports/           # Report generation
│   ├── audit_report.ex
│   └── pdf_generator.ex
├── automation/        # Automation management
│   ├── campaigns.ex
│   ├── campaign.ex
│   └── automation_result.ex
├── wikis/             # Wiki page management (core solution)
│   ├── wikis.ex
│   ├── wiki_page.ex
│   ├── wiki_platform.ex
│   └── wiki_content.ex
└── web/               # Phoenix web layer
    ├── router.ex
    ├── controllers/
    ├── live/
    └── components/
```

### 3.2 Test Structure

```
test/
├── thevis/
│   ├── accounts/
│   ├── projects/
│   ├── scans/
│   ├── geo/
│   └── ai/
├── support/
│   ├── factories.ex
│   └── mocks.ex
└── integration/
```

---

## 4. Core Contexts & Modules

### 4.1 Accounts Context

**Purpose:** User and company management

**Modules:**
- `Thevis.Accounts` - Public API
- `Thevis.Accounts.User` - User schema
- `Thevis.Accounts.Company` - Company schema
- `Thevis.Accounts.Role` - Role schema (client/consultant)

**Key Functions:**
```elixir
# Thevis.Accounts
create_user(attrs)
update_user(user, attrs)
get_user(id)
list_users(opts)

create_company(attrs)
update_company(company, attrs)
get_company(id)
list_companies(opts)
list_companies_with_products_in_launch_window(opts)  # Get companies with products in launch window

add_competitor(company, competitor_attrs)  # Add competitor to array
remove_competitor(company, competitor_index)  # Remove competitor by index
update_competitor(company, competitor_index, competitor_attrs)  # Update competitor by index
list_competitors(company)  # Returns competitors array

assign_role(user, company, role)
```

**Schema Fields:**

**User:**
- id, email, name, encrypted_password
- role (consultant/client)
- inserted_at, updated_at

**Company:**
- id, name, domain, industry
- description, website_url
- company_type: enum(:product_based, :service_based)  # Determines what we optimize
- competitors: array of maps (JSONB)  # Array of competitor companies
- inserted_at, updated_at

**Note:** 
- Product-based companies: Launch-related fields (launch_date, launch_window_start/end) are on Product
- Service-based companies: Company IS the service, optimized directly (no products)

**Role:**
- id, user_id, company_id
- role_type (consultant/client)
- inserted_at, updated_at

### 4.2 Products Context

**Purpose:** Product management - products are optimized for product-based companies

**Key Distinction:**
- **Product-Based Company** = Company that makes products (e.g., "Acme Cosmetics Inc.")
- **Product** = A specific product we optimize (e.g., "Glow Serum" - a specific cosmetic product)
- **Product Category** = Group of products optimized together (e.g., "all skincare products")
- We optimize products (or product categories) for product-based companies
- **Service-Based Company** = Company that provides services (e.g., "Visa Assistance Co.")
- **Service** = The company itself IS the service (optimized in Accounts context, not Products)
- We optimize the service (company) for service-based companies

**Modules:**
- `Thevis.Products` - Public API
- `Thevis.Products.Product` - Product schema
- `Thevis.Products.CompetitorProduct` - Competitor product schema

**Key Functions:**
```elixir
# Thevis.Products
create_product(company, attrs)
update_product(product, attrs)
get_product(id)
list_products(company)
list_products_in_launch_window(opts)

add_competitor_product(product, attrs)
remove_competitor_product(product, competitor_id)
list_competitor_products(product)
```

**Schema Fields:**

**Product:**
- id, company_id, name
- description, category
- product_type: enum(:cosmetic, :edible, :sweet, :d2c, :fashion, :wellness, :other)
- launch_date: date (nullable)  # Only for new product launches
- launch_window_start: date (nullable)  # Only for new product launches
- launch_window_end: date (nullable)  # Only for new product launches
- launch_window_active: boolean (computed field - not stored, derived from dates)
- inserted_at, updated_at

**Note:** Launch window fields are only used for new product launches. Existing products (ongoing_monitoring projects) don't have launch windows.

**CompetitorProduct:**
- id, product_id, name
- description, category
- brand_name: string (nullable)
- inserted_at, updated_at

### 4.2.1 Competitor Companies (for Company-Level Optimization)

**Purpose:** Track competitor companies when optimizing companies directly

**Implementation:** Competitors are stored as an array (JSONB) on the Company schema

**Key Functions:**
```elixir
# Thevis.Accounts
add_competitor(company, competitor_attrs)  # Add competitor to array
remove_competitor(company, competitor_index)  # Remove competitor by index
update_competitor(company, competitor_index, competitor_attrs)  # Update competitor by index
list_competitors(company)  # Returns competitors array
```

**Competitor Structure (stored in competitors array):**
- name: string
- domain: string
- industry: string (optional)
- notes: string (optional)

### 4.3 Projects Context

**Purpose:** Project management - projects are tied to products OR services (polymorphic)

**Key Distinction:**
- **Product-Based Companies**: Projects optimize products (e.g., "Glow Serum" or "all skincare products")
- **Service-Based Companies**: Projects optimize services (the company itself, e.g., "best company for visa assistance")
- Projects are polymorphic - can optimize products or services based on company type
- **Product Category Projects**: Can optimize all products in a category together

**Modules:**
- `Thevis.Projects` - Public API
- `Thevis.Projects.Project` - Project schema (polymorphic)

**Key Functions:**
```elixir
# Thevis.Projects
create_project_for_product(product, attrs)  # For product-based companies
create_project_for_product_category(products, category, attrs)  # Optimize category together
create_project_for_service(company, attrs)  # For service-based companies (company IS service)
update_project(project, attrs)
get_project(id)
list_projects_for_product(product)
list_projects_for_service(company)  # Service = company for service-based companies
list_projects_by_company(company)  # Get all projects (products/services) for a company
```

**Schema Fields:**

**Project:**
- id, name, description, status
- scan_frequency
- project_type: enum(:product_launch, :ongoing_monitoring, :audit_only)
  - `:product_launch` - New product launches (with launch windows, high intensity)
  - `:ongoing_monitoring` - Existing products or services (ongoing optimization, sustainable pace)
  - `:audit_only` - One-time audit/assessment
- urgency_level: enum(:standard, :high, :critical)
- is_category_project: boolean  # True if optimizing product category (multiple products together)
- **Polymorphic association:**
  - optimizable_type: enum(:product, :service)  # What we're optimizing
  - optimizable_id: uuid  # ID of product or company (for services, company_id)
- inserted_at, updated_at

**Note:** 
- `:product_launch` projects: For new products with launch windows (high intensity, aggressive automation)
- `:ongoing_monitoring` projects: For existing products or services (sustainable optimization, regular monitoring)
- Launch window dates accessed via `project.optimizable.launch_window_start/end` (only for new products)
- For service projects: No launch window (services don't have launch windows)
- Product category projects: `is_category_project = true`, optimizes multiple products together
- Competitors managed in respective contexts (CompetitorProduct or CompetitorCompany)

### 4.4 Scans Context

**Purpose:** Scan execution and result management

**Modules:**
- `Thevis.Scans` - Public API
- `Thevis.Scans.ScanRun` - Scan execution schema
- `Thevis.Scans.ScanResult` - Scan result schema

**Key Functions:**
```elixir
# Thevis.Scans
create_scan_run(project, attrs)
execute_scan(scan_run)
get_scan_run(id)
list_scan_runs(project)

create_scan_result(scan_run, attrs)
get_latest_results(project)
```

**Schema Fields:**

**ScanRun:**
- id, project_id, status
- scan_type, started_at, completed_at
- inserted_at, updated_at

**ScanResult:**
- id, scan_run_id, result_type
- data (jsonb), metrics (jsonb)
- inserted_at, updated_at

---

## 5. GEO Core Engines

### 5.1 Entity Probe Engine

**Purpose:** Determine if and how AI recognizes the product or company

**Modules:**
- `Thevis.Geo.EntityProbe` - Main probe engine
- `Thevis.Geo.PromptTemplates` - Prompt template management
- `Thevis.Geo.EntityParser` - Response parsing

**Key Functions:**
```elixir
# Thevis.Geo.EntityProbe
probe_entity(optimizable, options)  # Can be product or company
probe_with_prompt(optimizable, prompt_template)
analyze_response(response, optimizable)

# Thevis.Geo.PromptTemplates
get_template(type)
list_templates()
create_template(attrs)

# Thevis.Geo.EntityParser
parse_entity_response(response)
extract_description(response)
calculate_confidence(response, company)
```

**Outputs:**
- `EntitySnapshot` - Structured entity recognition data
- Confidence Score - How confident AI is about the entity

**Implementation Details:**
- Uses GenServer for state management
- Supports multiple prompt templates
- Caches recent probe results
- Handles rate limiting

### 5.2 Recall Engine

**Purpose:** Measure unprompted AI visibility for products or companies

**Modules:**
- `Thevis.Geo.RecallTest` - Recall testing logic
- `Thevis.Geo.RecallScorer` - Scoring and analysis

**Key Functions:**
```elixir
# Thevis.Geo.RecallTest
test_recall(optimizable, prompt_categories)  # Can be product or company
generate_test_prompts(categories, optimizable_type)  # Different prompts for products vs companies
execute_recall_test(prompts, optimizable)

# Thevis.Geo.RecallScorer
calculate_recall_percentage(results)
calculate_first_mention_rank(results)
compare_with_competitors(results, competitors)  # Can be competitor products or companies
```

**Outputs:**
- Recall Percentage - % of prompts where company is mentioned
- Mention Rank - Average position when mentioned

**Implementation Details:**
- Batch processing for multiple prompts
- Parallel execution using Task.Supervisor
- Result aggregation and analysis
- Historical comparison

### 5.3 Authority Engine

**Purpose:** Identify AI training signals and authority sources for products or companies

**Modules:**
- `Thevis.Geo.Crawler` - Web crawling for sources
- `Thevis.Geo.AuthorityGraph` - Authority relationship mapping

**Key Functions:**
```elixir
# Thevis.Geo.Crawler
crawl_source(source_type, optimizable)  # Can be product or company
crawl_github(optimizable)
crawl_medium(optimizable)
crawl_news(optimizable)

# Thevis.Geo.AuthorityGraph
build_authority_graph(optimizable)
calculate_authority_score(sources)
identify_gaps(optimizable, competitors)  # Can be competitor products or companies
```

**Sources:**
- GitHub repositories
- Medium articles
- News articles
- Company website
- Documentation sites

**Implementation Details:**
- Rate-limited crawling
- Content extraction and analysis
- Authority scoring algorithm
- Gap identification

### 5.4 Consistency / Drift Engine

**Purpose:** Detect messaging variance across sources for products or companies

**Modules:**
- `Thevis.Geo.Consistency` - Consistency analysis
- `Thevis.Geo.Vectorizer` - Text vectorization

**Key Functions:**
```elixir
# Thevis.Geo.Consistency
analyze_consistency(optimizable, sources)  # Can be product or company
calculate_drift_score(descriptions)
detect_variance(optimizable, ai_description)  # Can be product or company

# Thevis.Geo.Vectorizer
vectorize_text(text)
calculate_similarity(vector1, vector2)
find_similar_descriptions(company)
```

**Outputs:**
- Drift Score - Measure of messaging variance
- Consistency Report - Detailed variance analysis

**Implementation Details:**
- Uses pgvector for similarity search
- Text embedding generation
- Semantic similarity calculation
- Historical drift tracking

### 5.5 Internal Strategy Engine (Private)

**Purpose:** Consultant enablement tools

**Modules:**
- `Thevis.Geo.Strategy.OpportunityDetector` - Opportunity identification
- `Thevis.Geo.Strategy.PlaybookSelector` - Playbook selection
- `Thevis.Geo.Strategy.NarrativeBuilder` - Narrative construction
- `Thevis.Geo.Strategy.ExecutionPlanner` - Execution planning

**Key Functions:**
```elixir
# Thevis.Geo.Strategy.OpportunityDetector
detect_opportunities(project, scan_results)
rank_opportunities(opportunities)
categorize_opportunities(opportunities)

# Thevis.Geo.Strategy.PlaybookSelector
select_playbook(project, opportunities)
get_recommended_playbooks(project)
create_custom_playbook(attrs)

# Thevis.Geo.Strategy.NarrativeBuilder
build_narrative(company, playbook)
generate_narrative_rules(narrative)
test_narrative(narrative, prompts)

# Thevis.Geo.Strategy.ExecutionPlanner
create_execution_plan(project, playbook)
generate_tasks(plan)
estimate_timeline(plan)
```

**Access Control:**
- Only accessible to consultant role
- Not exposed in client-facing APIs
- Separate LiveView routes

### 4.6 Billing Context

**Purpose:** Subscription and billing management for package-based pricing

**Modules:**
- `Thevis.Billing` - Public API
- `Thevis.Billing.Subscription` - Subscription schema
- `Thevis.Billing.Invoice` - Invoice schema
- `Thevis.Billing.Payment` - Payment schema
- `Thevis.Billing.PackagePricing` - Package pricing configuration schema

**Key Functions:**
```elixir
# Thevis.Billing.Subscription
create_subscription(project, tier, duration, attrs)
activate_subscription(subscription)
expire_subscription(subscription)
cancel_subscription(subscription, reason)
renew_subscription(subscription)
get_active_subscription(project)
calculate_package_price(subscription_type, tier, duration, discounts)
apply_discounts(base_price, company, subscription_type)
check_subscription_status(project)  # Returns :active, :expired, :pending_payment
list_subscriptions(company, filters)

# Thevis.Billing.Invoice
create_invoice(subscription, attrs)
send_invoice(invoice)
mark_invoice_paid(invoice, payment_details)
generate_invoice_pdf(invoice)
list_invoices(company, filters)

# Thevis.Billing.Payment
create_payment(invoice, payment_method, attrs)
process_payment(payment)
handle_payment_webhook(provider, payload)
refund_payment(payment, reason)

# Thevis.Billing.PackagePricing
get_pricing(subscription_type, tier, duration)
update_pricing(pricing, attrs)
list_active_pricings()
calculate_discount(duration)  # Returns 0, 10, or 20 based on duration
```

**Package Pricing Logic:**
- **3 months**: No discount (0%)
- **6 months**: 10% discount
- **12 months**: 20% discount
- Multi-product/service discounts applied on top of package discount
- Pricing stored in `PackagePricing` table for easy updates

**Subscription Types:**
- `:product_optimization` - For product-based companies
- `:service_optimization` - For service-based companies
- `:product_launch` - For product launch packages (separate from ongoing)

**Tiers:**
- `:starter` - Basic optimization
- `:professional` - Enhanced optimization
- `:enterprise` - Maximum optimization

**Durations:**
- `:three_months` - 3-month package
- `:six_months` - 6-month package
- `:twelve_months` - 12-month package

### 5.6 Automation Engines

**Purpose:** Automatically execute strategies to improve AI presence

**Modules:**
- `Thevis.Geo.Automation.Optimizer` - Main automation orchestrator
- `Thevis.Geo.Automation.ContentCreator` - Automated content generation
- `Thevis.Geo.Automation.Publisher` - Multi-platform publishing
- `Thevis.Geo.Automation.AuthorityBuilder` - Authority building automation
- `Thevis.Geo.Automation.ConsistencyManager` - Consistency automation

**Key Functions:**
```elixir
# Thevis.Geo.Automation.Optimizer
create_campaign(project, playbook, options)
execute_campaign(campaign)
monitor_campaign(campaign)
optimize_campaign(campaign, results)

# Thevis.Geo.Automation.ContentCreator
generate_content(project, content_type, narrative)
optimize_for_ai(content, company)
create_wiki_page(project, narrative, platform)  # Primary content type
create_wikipedia_page(project, narrative)        # Automated Wikipedia creation
create_company_wiki_page(project, narrative)     # Automated company wiki
create_github_readme(project, narrative)
create_blog_post(project, topic, narrative)
create_documentation_page(project, section, narrative)

# Thevis.Geo.Automation.Publisher
publish_wiki_page(wiki_content, platform, options)  # Primary publishing
publish_to_wikipedia(wiki_content, options)       # Automated Wikipedia
publish_to_company_wiki(wiki_content, options)   # Automated company wiki
publish_to_github(content, repository, options)
publish_to_medium(content, options)
publish_to_blog(content, options)
schedule_publication(content, platform, schedule_time)

# Thevis.Geo.Automation.AuthorityBuilder
optimize_github_repo(project, repository)
update_documentation(project, updates)
create_technical_content(project, topics)
build_authority_signals(project, strategy)
generate_citations(project, narrative)  # Comprehensive citation generation
place_citations(project, citations, targets)  # Citation placement across platforms
build_links(project, strategy)  # Link building automation
outreach_for_links(project, targets)  # Backlink outreach
engage_community(project, platforms, content)  # Community engagement
optimize_social_media(project, platforms)  # Social media optimization
distribute_press_release(project, press_release, outlets)  # Press release distribution
place_news_articles(project, articles, publications)  # News/article placement
optimize_review_platforms(project, platforms)  # Review platform optimization
create_directory_listings(project, directories)  # Directory listing creation
generate_citations(project, narrative)  # Comprehensive citation generation
place_citations(project, citations, targets)  # Citation placement across platforms
build_links(project, strategy)  # Link building automation
outreach_for_links(project, targets)  # Backlink outreach
engage_community(project, platforms, content)  # Community engagement
optimize_social_media(project, platforms)  # Social media optimization
distribute_press_release(project, press_release, outlets)  # Press release distribution
place_news_articles(project, articles, publications)  # News/article placement
optimize_review_platforms(project, platforms)  # Review platform optimization
create_directory_listings(project, directories)  # Directory listing creation

# Thevis.Geo.Automation.ConsistencyManager
detect_inconsistencies(project)
synchronize_messaging(project, narrative)
sync_wiki_pages(project, narrative)              # Automatic wiki sync
update_wiki_from_narrative(project, narrative)   # Automatic wiki updates
update_all_sources(project, updates)
fix_drift(project, drift_issues)
```

**Implementation Details:**
- Uses GenServer for campaign state management
- Background job execution via Oban
- Fully automated execution (no approval workflows)
- Comprehensive logging and auditing
- Performance tracking and optimization
- **Product Launch Mode** (`project_type: :product_launch`): Higher intensity campaigns for new product launches
  - Increased content generation frequency (2x multiplier)
  - Prioritized wiki page creation
  - Aggressive publishing schedules
  - Launch window deadline awareness
  
- **Ongoing Monitoring Mode** (`project_type: :ongoing_monitoring`): Sustainable optimization for existing products/companies
  - Standard content generation frequency
  - Regular wiki page updates and optimization
  - Scheduled publishing (sustainable pace)
  - Long-term visibility maintenance

**Automation Workflow (Wiki-Integrated):**
1. Campaign created from playbook and opportunities
2. Content generated based on narratives
   - **Wiki pages generated as primary content**
   - **Wikipedia pages generated automatically**
   - **Company wikis generated automatically**
   - Other content types generated
3. Content optimized for AI training signals
   - **Wiki content optimized for AI training**
   - Other content optimized
4. Publishing scheduled or executed immediately
   - **Wiki pages published automatically** (fully automated)
   - Other content published
5. Performance tracked and measured
   - **Wiki page performance tracked**
   - **GEO score impact measured**
6. Campaign optimized based on results
   - **Wiki pages automatically updated based on results**
   - Campaign strategy refined

### 5.7 Wiki Automation (Integrated in Automation Engine)

**Purpose:** Wiki pages are automatically created, updated, and managed as part of the automation engine

**Note:** Wiki management is integrated into the Automation Engines, not a separate system. Wiki pages are the primary content type generated by automation.

**Modules (Integrated):**
- Wiki functionality integrated into `Thevis.Geo.Automation.ContentCreator`
- Wiki publishing integrated into `Thevis.Geo.Automation.Publisher`
- Wiki sync integrated into `Thevis.Geo.Automation.ConsistencyManager`
- Wiki authority building integrated into `Thevis.Geo.Automation.AuthorityBuilder`
- `Thevis.Wikis` - Wiki context for data management
- `Thevis.Wikis.WikiPage` - Wiki page schema
- `Thevis.Wikis.WikiPlatform` - Platform integration (Wikipedia, company wikis)
- `Thevis.Wikis.WikiContent` - Wiki content generation and optimization

**Key Functions (Called Automatically by Automation Engines):**
```elixir
# Called automatically by ContentCreator during campaigns
Thevis.Geo.Automation.ContentCreator.create_wiki_page(project, narrative, platform)
Thevis.Geo.Automation.ContentCreator.create_wikipedia_page(project, narrative)
Thevis.Geo.Automation.ContentCreator.create_company_wiki_page(project, narrative)

# Called automatically by Publisher during campaigns
Thevis.Geo.Automation.Publisher.publish_wiki_page(wiki_content, platform, options)
Thevis.Geo.Automation.Publisher.publish_to_wikipedia(wiki_content, options)

# Called automatically by ConsistencyManager during sync
Thevis.Geo.Automation.ConsistencyManager.sync_wiki_pages(project, narrative)
Thevis.Geo.Automation.ConsistencyManager.update_wiki_from_narrative(project, narrative)

# Called automatically by AuthorityBuilder during authority campaigns
Thevis.Geo.Automation.AuthorityBuilder.create_authority_wikis(project, narrative)

# Wiki context (data management)
Thevis.Wikis.get_wiki_page(id)
Thevis.Wikis.list_wiki_pages(project)
Thevis.Wikis.track_wiki_performance(wiki_page)
```

**Automated Wiki Integration:**

**During Content Creation:**
- Wiki pages automatically generated as primary content type
- Wikipedia pages automatically created (fully automated)
- Company wikis automatically created
- Content automatically optimized for AI training

**During Campaign Execution:**
- Wiki pages automatically created as part of campaigns
- Wiki pages automatically published to appropriate platforms
- Wikipedia edits automatically submitted (fully automated)
- Company wikis automatically updated

**During Narrative Updates:**
- Wiki pages automatically detected for updates
- Wiki content automatically regenerated from new narrative
- Wiki pages automatically synchronized across platforms
- Wikipedia pages automatically updated (fully automated)

**During Consistency Management:**
- Wiki inconsistencies automatically detected
- Wiki pages automatically synchronized with narrative
- Multi-wiki synchronization automatic

**Wiki Platforms (Automated):**
- Wikipedia (via API, fully automated)
- Company wikis (Confluence, Notion, custom - fully automated)
- Knowledge bases (automated updates)
- Documentation sites (automated)

**Implementation Details:**
- Wikipedia API integration (with rate limiting)
- Company wiki API integrations
- Content generation optimized for AI training signals
- Wikipedia compliance checking (notability, NPOV, sources)
- **Fully automated update workflows**
- Performance tracking and GEO score correlation
- Fully automated Wikipedia management (no approval workflows)
- **Automatic multi-wiki synchronization**

**Wiki Content Optimization (Automatic):**
- Structured data (infoboxes, categories) automatically added
- Comprehensive company coverage automatically ensured
- Semantic markup and metadata automatically added
- Authority sources and citations automatically generated
- Consistent terminology automatically maintained
- AI training signal optimization automatic

---

## 6. Data Models

### 6.1 Core Schemas

**User**
```elixir
%{
  id: uuid,
  email: string,
  name: string,
  encrypted_password: string,
  role: enum(:consultant, :client),
  inserted_at: datetime,
  updated_at: datetime
}
```

**Company**
```elixir
%{
  id: uuid,
  name: string,
  domain: string,
  industry: string,
  description: text,
  website_url: string,
  company_type: enum(:product_based, :service_based),
  competitors: [%{name: string, domain: string, industry: string, notes: string}],  # JSONB array
  inserted_at: datetime,
  updated_at: datetime
}
```

**Product**
```elixir
%{
  id: uuid,
  company_id: uuid,  # The client company
  name: string,  # Product name (e.g., "Glow Serum")
  description: text,
  category: string,  # e.g., "cosmetics", "edibles", "sweets", "d2c"
  product_type: enum(:cosmetic, :edible, :sweet, :d2c, :fashion, :wellness, :other),
  launch_date: date (nullable),  # Only for new product launches
  launch_window_start: date (nullable),  # Only for new product launches
  launch_window_end: date (nullable),  # Only for new product launches
  # launch_window_active: computed field (derived from dates, not stored)
  inserted_at: datetime,
  updated_at: datetime
}
# Note: Launch window fields are only populated for new product launches.
#      Existing products (ongoing_monitoring projects) leave these fields null.
```

**Project**
```elixir
%{
  id: uuid,
  name: string,
  description: text,
  status: enum(:active, :paused, :archived),
  scan_frequency: enum(:daily, :weekly, :monthly),
  project_type: enum(:product_launch, :ongoing_monitoring, :audit_only),
  urgency_level: enum(:standard, :high, :critical),
  # Polymorphic association - can optimize product or company
  optimizable_type: enum(:product, :company),
  optimizable_id: uuid,  # ID of product or company
  inserted_at: datetime,
  updated_at: datetime
  # Note: For products, launch window dates accessed via project.optimizable.launch_window_start/end
  # Note: For companies, no launch window (companies don't have launch windows)
}
```

**ScanRun**
```elixir
%{
  id: uuid,
  project_id: uuid,
  status: enum(:pending, :running, :completed, :failed),
  scan_type: enum(:entity_probe, :recall, :authority, :consistency, :full),
  started_at: datetime,
  completed_at: datetime,
  inserted_at: datetime,
  updated_at: datetime
}
```

**EntitySnapshot**
```elixir
%{
  id: uuid,
  scan_run_id: uuid,
  # Polymorphic - can be for product or company
  optimizable_type: enum(:product, :company),
  optimizable_id: uuid,  # ID of product or company
  ai_description: text,  # AI's description of the product/company
  confidence_score: float,
  source_llm: string,
  prompt_template: string,
  inserted_at: datetime
}
```

**RecallResult**
```elixir
%{
  id: uuid,
  scan_run_id: uuid,
  project_id: uuid,
  recall_percentage: float,
  first_mention_rank: integer,
  total_prompts: integer,
  mentions: integer,
  category_breakdown: jsonb,
  inserted_at: datetime
}
```

**AuthorityScore**
```elixir
%{
  id: uuid,
  scan_run_id: uuid,
  # Polymorphic - can be for product or company
  optimizable_type: enum(:product, :company),
  optimizable_id: uuid,  # ID of product or company
  overall_score: float,
  github_score: float,
  medium_score: float,
  news_score: float,
  source_count: integer,
  inserted_at: datetime
}
```

**DriftScore**
```elixir
%{
  id: uuid,
  scan_run_id: uuid,
  # Polymorphic - can be for product or company
  optimizable_type: enum(:product, :company),
  optimizable_id: uuid,  # ID of product or company
  drift_score: float,
  consistency_score: float,
  variance_details: jsonb,
  inserted_at: datetime
}
```

### 6.2 Internal Schemas (Consultant Only)

**Narrative**
```elixir
%{
  id: uuid,
  project_id: uuid,
  content: text,
  rules: jsonb,
  version: integer,
  is_active: boolean,
  inserted_at: datetime,
  updated_at: datetime
}
```

**Playbook**
```elixir
%{
  id: uuid,
  name: string,
  description: text,
  category: string,
  steps: jsonb,
  is_template: boolean,
  project_id: uuid (nullable),
  inserted_at: datetime,
  updated_at: datetime
}
```

### 6.3 Automation Schemas

**Campaign**
```elixir
%{
  id: uuid,
  project_id: uuid,
  playbook_id: uuid,
  name: string,
  description: text,
  status: enum(:draft, :active, :paused, :completed, :failed),
  campaign_type: enum(:content, :authority, :consistency, :full, :product_launch),
  intensity: enum(:standard, :high, :critical),  # Higher for product launches
  launch_window_mode: boolean,  # Indicates if campaign is in launch window
  goals: jsonb,
  settings: jsonb,
  started_at: datetime,
  completed_at: datetime,
  inserted_at: datetime,
  updated_at: datetime
}
```

**AutomationResult**
```elixir
%{
  id: uuid,
  campaign_id: uuid,
  action_type: enum(:content_created, :content_published, :authority_built, :consistency_fixed),
  action_details: jsonb,
  status: enum(:pending, :approved, :executed, :failed),
  approved_by: uuid (nullable),
  approved_at: datetime (nullable),
  executed_at: datetime (nullable),
  performance_metrics: jsonb,
  inserted_at: datetime,
  updated_at: datetime
}
```

**ContentItem**
```elixir
%{
  id: uuid,
  campaign_id: uuid,
  project_id: uuid,
  content_type: enum(:blog_post, :github_readme, :documentation, :article, :wiki_page),
  title: string,
  content: text,
  platform: enum(:github, :medium, :blog, :docs, :wikipedia, :company_wiki),
  status: enum(:draft, :scheduled, :published, :failed),
  published_url: string (nullable),
  ai_optimization_score: float,
  performance_metrics: jsonb,
  scheduled_at: datetime (nullable),
  published_at: datetime (nullable),
  inserted_at: datetime,
  updated_at: datetime
}
```

### 6.4 Subscription & Billing Schemas

**Subscription**
```elixir
%{
  id: uuid,
  project_id: uuid,
  company_id: uuid,
  subscription_type: enum(:product_optimization, :service_optimization, :product_launch),
  tier: enum(:starter, :professional, :enterprise),
  package_duration: enum(:three_months, :six_months, :twelve_months),
  package_price_min: decimal,  # Minimum price for tier/duration
  package_price_max: decimal,  # Maximum price for tier/duration
  actual_price: decimal,  # Final price after discounts
  discount_percentage: float,  # Applied discount (0-20%)
  status: enum(:active, :expired, :cancelled, :pending_payment),
  started_at: datetime,
  expires_at: datetime,
  auto_renew: boolean,
  payment_status: enum(:paid, :pending, :failed, :refunded),
  payment_method: string (nullable),
  payment_provider: enum(:stripe, :paypal, :wire_transfer, :manual),
  payment_provider_id: string (nullable),  # External payment ID
  inserted_at: datetime,
  updated_at: datetime
}
```

**Invoice**
```elixir
%{
  id: uuid,
  subscription_id: uuid,
  company_id: uuid,
  invoice_number: string,  # Unique invoice number
  amount: decimal,
  currency: string,  # Default: USD
  status: enum(:draft, :sent, :paid, :overdue, :cancelled),
  due_date: date,
  paid_at: datetime (nullable),
  payment_method: string (nullable),
  payment_provider: enum(:stripe, :paypal, :wire_transfer, :manual),
  payment_provider_id: string (nullable),
  line_items: jsonb,  # Breakdown of charges
  tax_amount: decimal (nullable),
  discount_amount: decimal (nullable),
  total_amount: decimal,
  notes: text (nullable),
  inserted_at: datetime,
  updated_at: datetime
}
```

**Payment**
```elixir
%{
  id: uuid,
  invoice_id: uuid,
  subscription_id: uuid,
  amount: decimal,
  currency: string,
  payment_method: string,
  payment_provider: enum(:stripe, :paypal, :wire_transfer, :manual),
  payment_provider_id: string,  # External payment ID
  status: enum(:pending, :processing, :completed, :failed, :refunded),
  transaction_id: string (nullable),
  receipt_url: string (nullable),
  failure_reason: string (nullable),
  processed_at: datetime (nullable),
  inserted_at: datetime,
  updated_at: datetime
}
```

**PackagePricing**
```elixir
%{
  id: uuid,
  subscription_type: enum(:product_optimization, :service_optimization, :product_launch),
  tier: enum(:starter, :professional, :enterprise),
  duration: enum(:three_months, :six_months, :twelve_months),
  price_min: decimal,
  price_max: decimal,
  discount_percentage: float,  # Discount for this duration (0, 10, or 20)
  is_active: boolean,
  effective_from: date,
  effective_until: date (nullable),
  inserted_at: datetime,
  updated_at: datetime
}
```

### 6.5 Wiki Schemas (Core Solution)

**WikiPage**
```elixir
%{
  id: uuid,
  project_id: uuid,
  platform: enum(:wikipedia, :company_wiki, :knowledge_base, :other),
  platform_name: string,
  page_title: string,
  page_url: string (nullable),
  content: text,
  structured_data: jsonb,
  status: enum(:draft, :published, :needs_update, :archived),
  wikipedia_compliance_status: enum(:compliant, :needs_review, :non_compliant) (nullable),
  ai_optimization_score: float,
  geo_score_impact: float (nullable),
  performance_metrics: jsonb,
  last_synced_at: datetime (nullable),
  last_updated_at: datetime (nullable),
  inserted_at: datetime,
  updated_at: datetime
}
```

**WikiContent**
```elixir
%{
  id: uuid,
  wiki_page_id: uuid,
  version: integer,
  content: text,
  structured_data: jsonb,
  citations: jsonb,
  infobox_data: jsonb,
  categories: array(string),
  metadata: jsonb,
  ai_optimization_score: float,
  is_current: boolean,
  created_by: uuid,
  inserted_at: datetime,
  updated_at: datetime
}
```

**WikiPlatform**
```elixir
%{
  id: uuid,
  project_id: uuid,
  platform_type: enum(:wikipedia, :confluence, :notion, :custom),
  platform_name: string,
  api_endpoint: string (nullable),
  api_key: string (encrypted, nullable),
  credentials: jsonb (encrypted),
  is_active: boolean,
  sync_enabled: boolean,
  inserted_at: datetime,
  updated_at: datetime
}
```

---

## 7. AI/LLM Integration

### 7.1 Adapter Pattern

**Behaviour:**
```elixir
defmodule Thevis.AI.Adapter do
  @callback chat_completion(messages :: list(), opts :: keyword()) ::
              {:ok, response :: map()} | {:error, reason :: term()}
  
  @callback embed_text(text :: String.t()) ::
              {:ok, embedding :: list(float())} | {:error, reason :: term()}
end
```

**Implementations:**
- `Thevis.AI.OpenAIAdapter` - OpenAI API integration
- `Thevis.AI.AnthropicAdapter` - Anthropic API integration

**Configuration:**
- Provider selection via config
- API key management
- Rate limiting
- Retry logic with exponential backoff

### 7.2 Usage Pattern

```elixir
# Get configured adapter
adapter = Thevis.AI.get_adapter()

# Use adapter
case adapter.chat_completion(messages, temperature: 0.7) do
  {:ok, response} -> process_response(response)
  {:error, reason} -> handle_error(reason)
end
```

---

## 8. Background Jobs

### 8.1 Oban Configuration

**Job Types:**
- `Thevis.Jobs.ScanExecution` - Execute scans
- `Thevis.Jobs.EntityProbe` - Run entity probes
- `Thevis.Jobs.RecallTest` - Execute recall tests
- `Thevis.Jobs.AuthorityCrawl` - Crawl authority sources
- `Thevis.Jobs.ReportGeneration` - Generate PDF reports
- `Thevis.Jobs.CampaignExecution` - Execute automation campaigns
- `Thevis.Jobs.ContentGeneration` - Generate content
- `Thevis.Jobs.ContentPublishing` - Publish content
- `Thevis.Jobs.AuthorityBuilding` - Build authority signals
- `Thevis.Jobs.ConsistencyFix` - Fix consistency issues
- `Thevis.Jobs.WikiPageCreation` - Create wiki pages
- `Thevis.Jobs.WikiPageUpdate` - Update wiki pages
- `Thevis.Jobs.WikiSync` - Sync wiki pages with narratives
- `Thevis.Jobs.WikiPerformanceTracking` - Track wiki performance
- `Thevis.Jobs.SubscriptionExpiryCheck` - Check and handle expiring subscriptions
- `Thevis.Jobs.InvoiceGeneration` - Generate invoices for subscriptions
- `Thevis.Jobs.PaymentReminder` - Send payment reminders

**Scheduling:**
- Recurring scans based on project frequency
- Scheduled authority crawls
- Periodic consistency checks
- Automated campaign execution
- Scheduled content publishing
- Periodic automation optimization
- Wiki page creation and updates
- Wiki page synchronization with narratives
- Wiki performance monitoring

### 8.2 Job Implementation Pattern

```elixir
defmodule Thevis.Jobs.ScanExecution do
  use Oban.Worker, queue: :scans, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"scan_run_id" => scan_run_id}}) do
    # Execute scan logic
  end
end
```

---

## 9. API Design

### 9.1 LiveView Routes (Client-Facing)

```
GET  /                    # Dashboard
GET  /projects/:id        # Project dashboard
GET  /projects/:id/audit  # Audit report
GET  /projects/:id/recall # Recall report
GET  /projects/:id/history # Historical tracking
```

### 9.2 LiveView Routes (Billing)

```
GET  /billing/subscriptions        # List subscriptions
GET  /billing/subscriptions/:id    # Subscription details
GET  /billing/invoices            # List invoices
GET  /billing/invoices/:id        # Invoice details
GET  /billing/invoices/:id/pdf    # Download invoice PDF
POST /billing/subscriptions       # Create subscription
POST /billing/payments            # Process payment
```

### 9.3 LiveView Routes (Consultant)

```
GET  /consultant/projects           # Consultant dashboard
GET  /consultant/projects/:id      # Project details
GET  /consultant/projects/:id/opportunities # Opportunities
GET  /consultant/projects/:id/playbooks     # Playbooks
GET  /consultant/projects/:id/narratives    # Narratives
GET  /consultant/projects/:id/tasks         # Task board
GET  /consultant/projects/:id/campaigns     # Campaign management
GET  /consultant/projects/:id/automation    # Automation dashboard
GET  /consultant/campaigns/:id              # Campaign details
GET  /consultant/projects/:id/wikis         # Wiki page management
GET  /consultant/wikis/:id                  # Wiki page details
GET  /consultant/wikis/:id/edit             # Wiki page editor
```

### 9.4 JSON API Routes (Internal)

```
POST   /api/scans                    # Trigger scan
GET    /api/projects/:id/results     # Get results
POST   /api/reports/:id/generate     # Generate report
```

---

## 10. Security Considerations

### 10.1 Authentication

- Phoenix authentication (phx.gen.auth)
- Session-based authentication
- Password hashing with bcrypt

### 10.2 Authorization

- Role-based access control (RBAC)
- Context-level authorization checks
- Consultant-only route protection

### 10.3 Data Protection

- Encrypted API keys
- Secure session management
- Input validation at boundaries
- SQL injection prevention (Ecto)

---

## 11. Testing Strategy

### 11.1 Unit Tests

- Test all context functions
- Test GEO engine logic
- Test AI adapter implementations
- Use Mox for AI adapter mocking

### 11.2 Integration Tests

- Test full scan workflows
- Test report generation
- Test LiveView interactions

### 11.3 Test Factories

- Use ExMachina for test data
- Factory definitions for all schemas
- Trait support for different scenarios

### 11.4 Property-Based Testing

- Use StreamData for GEO engine tests
- Test edge cases with property tests

---

## 12. Iterative Build Plan (MVP → Full Feature Set)

### Iteration 1: MVP - Core GEO Measurement (Weeks 1-6)
**Goal:** Deliver basic GEO audit capability - measure current AI visibility

**Deliverables:**
1. Foundation (Weeks 1-2)
   - Project setup, database, authentication
   - Accounts context (User, Company, Role)
   - Products context (Product, CompetitorProduct)
   - Projects context (polymorphic)
   - Basic LiveView structure

2. Core Scanning (Weeks 3-4)
   - Scans context (ScanRun, ScanResult)
   - Entity Probe Engine
   - AI adapter (OpenAI)
   - Basic scan execution
   - Entity snapshot storage

3. Recall & Scoring (Weeks 5-6)
   - Recall Engine
   - Recall test execution
   - Recall scoring
   - GEO Score calculation
   - Metrics aggregation

**MVP Outcome:** Can run GEO audit, generate PDF report, show GEO Score and recall metrics

---

### Iteration 2: Client Dashboard & Reporting (Weeks 7-10)
**Goal:** Deliver client-facing dashboard with historical tracking

**Deliverables:**
1. Reporting (Weeks 7-8)
   - Audit report data collection
   - PDF report generation
   - Client dashboard (LiveView)
   - Historical tracking

2. Automation Foundation (Weeks 9-10)
   - Oban setup
   - Scheduled scans
   - Background job processing
   - Scan result notifications

**Outcome:** Clients can view their GEO Score, recall metrics, and historical trends

---

### Iteration 3: Authority & Consistency Analysis (Weeks 11-14)
**Goal:** Add authority and consistency analysis to audits

**Deliverables:**
1. Authority Analysis (Weeks 11-12)
   - Authority Engine
   - Web crawler
   - Authority scoring
   - Authority graph building

2. Consistency Analysis (Weeks 13-14)
   - Consistency Engine
   - Vector store setup (pgvector)
   - Text vectorization
   - Drift calculation

**Outcome:** Full audit includes authority scores and consistency analysis

---

### Iteration 4: Consultant Tools - Strategy (Weeks 15-18)
**Goal:** Enable consultants to build strategies and detect opportunities

**Deliverables:**
1. Internal Tools (Weeks 15-18)
   - Opportunity Detection Engine
   - Playbook Engine
   - Narrative Builder
   - Execution Planner
   - Consultant Task Board
   - Consultant LiveView routes

**Outcome:** Consultants can detect opportunities, build narratives, create playbooks

---

### Iteration 5: Wiki Optimization (Weeks 19-22)
**Goal:** Deliver wiki page creation and optimization as first optimization technique

**Deliverables:**
1. Wiki Management (Weeks 19-22)
   - Wiki Management Engine
   - Wiki Page Schema and Context
   - Wikipedia Integration (basic)
   - Company Wiki Integrations (basic)
   - Wiki Content Generation
   - Wiki Content Optimization for AI
   - Wikipedia Compliance Checking
   - Wiki Performance Tracking
   - Wiki-Narrative Synchronization

**Outcome:** Can automatically create and optimize wiki pages

---

### Iteration 6: Content Automation (Weeks 23-26)
**Goal:** Add content creation and publishing automation

**Deliverables:**
1. Content Automation (Weeks 23-26)
   - Content Creator Engine
   - Multi-platform Publisher (GitHub, Medium, company blog)
   - Content scheduling
   - Content performance tracking
   - Campaign Management System (basic)

**Outcome:** Can automatically create and publish blog posts, GitHub READMEs, documentation

---

### Iteration 7: Authority Building - Core (Weeks 27-30)
**Goal:** Add core authority building techniques

**Deliverables:**
1. Authority Building - Core (Weeks 27-30)
   - GitHub repository optimization
   - Documentation site updates
   - Technical blog post creation
   - Citation generation (basic)
   - Link building automation (basic)
   - Authority Building Automation integration

**Outcome:** Can automatically build authority through GitHub, docs, citations, and basic link building

---

### Iteration 8: Consistency Management (Weeks 31-34)
**Goal:** Add consistency management automation

**Deliverables:**
1. Consistency Management (Weeks 31-34)
   - Consistency Management Automation
   - Message synchronization
   - Automated updates across platforms
   - Drift detection and correction
   - Consistency monitoring

**Outcome:** Can automatically maintain consistent messaging across all platforms

---

### Iteration 9: Authority Building - Advanced (Weeks 35-38)
**Goal:** Add advanced authority building techniques

**Deliverables:**
1. Advanced Authority Building (Weeks 35-38)
   - Community engagement automation (Reddit, HackerNews, forums)
   - Social media optimization (LinkedIn, Twitter/X, Facebook)
   - Press release distribution
   - News/article placement
   - Review platform optimization (G2, Capterra, Trustpilot)
   - Directory listings

**Outcome:** Full authority building suite with all techniques

---

### Iteration 10: Full Automation & Campaigns (Weeks 39-42)
**Goal:** Complete automation system with full campaign management

**Deliverables:**
1. Full Automation (Weeks 39-42)
   - Automation Optimizer
   - Full Campaign Management System
   - Automation Performance Tracking
   - Fully Automated Execution (No Approval Workflows)
   - Campaign optimization
   - Multi-project management

**Outcome:** Fully automated campaigns with all optimization techniques

---

### Iteration 11: Polish & Scale (Weeks 43-46)
**Goal:** Production readiness and optimization

**Deliverables:**
1. Polish (Weeks 43-46)
   - Error handling improvements
   - Performance optimization
   - Comprehensive testing
   - Documentation
   - Deployment configuration
   - Monitoring and alerting

**Outcome:** Production-ready system

---

## 13. Task List (Iterative Implementation)

### 13.1 Iteration 1: MVP - Foundation (Weeks 1-2)

- [ ] Initialize Phoenix project with latest version
- [ ] Configure PostgreSQL database
- [ ] Set up Ecto and create initial migration
- [ ] Install and configure authentication (phx.gen.auth)
- [ ] Create User schema and context
- [ ] Create Company schema and context
- [ ] Create Role schema and associations
- [ ] Set up basic LiveView structure
- [ ] Create authentication LiveView pages
- [ ] Implement role-based access control
- [ ] Write tests for Accounts context
- [ ] Create Product schema and context (products are what we optimize)
- [ ] Create CompetitorProduct schema and associations
- [ ] Write tests for Products context
- [ ] Create Project schema and context (tied to products, not companies)
- [ ] Write tests for Projects context

### 13.2 Iteration 1: MVP - Core Scanning (Weeks 3-4)

- [ ] Create ScanRun schema
- [ ] Create ScanResult schema
- [ ] Implement Scans context
- [ ] Set up AI adapter behaviour
- [ ] Implement OpenAI adapter
- [ ] Create Entity Probe Engine module
- [ ] Create Prompt Templates module
- [ ] Create Entity Parser module
- [ ] Implement entity probing logic
- [ ] Store entity snapshots
- [ ] Create scan execution LiveView
- [ ] Write tests for Entity Probe Engine
- [ ] Write tests for Scans context

### 13.3 Iteration 1: MVP - Recall & Scoring (Weeks 5-6)

- [ ] Create Recall Engine module
- [ ] Implement recall test generation
- [ ] Implement recall test execution
- [ ] Create Recall Scorer module
- [ ] Calculate recall percentage
- [ ] Calculate first mention rank
- [ ] Implement competitor comparison
- [ ] Create GEO Score calculation logic
- [ ] Aggregate metrics from multiple scans
- [ ] Store recall results
- [ ] Write tests for Recall Engine
- [ ] Create recall visualization in LiveView

### 13.4 Iteration 2: Client Dashboard & Reporting (Weeks 7-8)

- [ ] Design audit report structure
- [ ] Collect report data from scans
- [ ] Set up PDF generation library
- [ ] Create PDF report template
- [ ] Implement report generation
- [ ] Create client dashboard LiveView
- [ ] Display GEO Score and metrics
- [ ] Create historical tracking views
- [ ] Implement chart visualizations
- [ ] Add export functionality
- [ ] Write tests for report generation
- [ ] Write tests for dashboard

### 13.5 Iteration 2: Automation Foundation (Weeks 9-10)

- [ ] Set up Oban
- [ ] Create scan execution job
- [ ] Create entity probe job
- [ ] Create recall test job
- [ ] Implement job scheduling
- [ ] Set up recurring scan jobs
- [ ] Implement job error handling
- [ ] Create job monitoring dashboard
- [ ] Add job retry logic
- [ ] Write tests for background jobs
- [ ] Test job scheduling

### 13.6 Iteration 3: Authority Analysis (Weeks 11-12)

- [ ] Create Authority Engine module
- [ ] Implement web crawler
- [ ] Create GitHub crawler
- [ ] Create Medium crawler
- [ ] Create news crawler
- [ ] Implement content extraction
- [ ] Create Authority Graph module
- [ ] Calculate authority scores
- [ ] Identify authority gaps
- [ ] Store authority data
- [ ] Write tests for Authority Engine
- [ ] Integrate authority into scans

### 13.7 Iteration 3: Consistency Analysis (Weeks 13-14)

- [ ] Set up pgvector extension
- [ ] Create vector storage schema
- [ ] Create Vectorizer module
- [ ] Implement text embedding
- [ ] Create Consistency module
- [ ] Calculate drift scores
- [ ] Detect messaging variance
- [ ] Store consistency data
- [ ] Write tests for Consistency Engine
- [ ] Integrate consistency into scans

### 13.8 Iteration 4: Consultant Tools - Strategy (Weeks 15-18)

- [ ] Create Opportunity Detector module
- [ ] Implement opportunity detection logic
- [ ] Create Playbook schema
- [ ] Create Playbook Engine module
- [ ] Implement playbook selection
- [ ] Create Narrative schema
- [ ] Create Narrative Builder module
- [ ] Implement narrative rules engine
- [ ] Create Execution Planner module
- [ ] Create Task schema
- [ ] Create consultant task board
- [ ] Create consultant LiveView routes
- [ ] Implement access control for consultant routes
- [ ] Write tests for Strategy modules

### 13.9 Iteration 5: Wiki Optimization (Weeks 19-22)

- [ ] Create WikiPage schema
- [ ] Create WikiContent schema
- [ ] Create WikiPlatform schema
- [ ] Create Wikis context
- [ ] Integrate wiki creation into ContentCreator automation
- [ ] Integrate wiki publishing into Publisher automation
- [ ] Integrate wiki sync into ConsistencyManager automation
- [ ] Integrate wiki authority building into AuthorityBuilder automation
- [ ] Implement automatic wiki page creation from narratives
- [ ] Implement automatic wiki content generation
- [ ] Implement automatic wiki content optimization for AI
- [ ] Create Wikipedia API integration
- [ ] Implement Wikipedia compliance checking
- [ ] Create company wiki integrations (Confluence, Notion)
- [ ] Implement automatic wiki page publishing
- [ ] Implement automatic wiki page updates
- [ ] Create automatic wiki-narrative synchronization
- [ ] Implement automatic wiki performance tracking
- [ ] Ensure fully automated Wikipedia management (no approval workflows)
- [ ] Create wiki management LiveView (for monitoring)
- [ ] Write tests for Wiki automation integration
- [ ] Create background jobs for wiki automation
- [ ] Implement wiki monitoring and alerts
- [ ] Test wiki automation in campaign workflows

### 13.10 Iteration 6: Content Automation (Weeks 23-26)

- [ ] Create Campaign schema
- [ ] Create AutomationResult schema
- [ ] Create ContentItem schema
- [ ] Create Automation context
- [ ] Create Content Creator Engine
- [ ] Implement content generation from narratives
- [ ] Implement content optimization for AI
- [ ] Create Multi-platform Publisher module
- [ ] Implement GitHub publishing
- [ ] Implement Medium publishing
- [ ] Implement blog publishing
- [ ] Create basic Campaign Management System
- [ ] Implement content scheduling
- [ ] Implement content performance tracking
- [ ] Create campaign management LiveView
- [ ] Write tests for Content Automation
- [ ] Create background jobs for content automation

### 13.11 Iteration 7: Authority Building - Core (Weeks 27-30)

- [ ] Create Authority Builder Automation module
- [ ] Implement GitHub repository optimization
- [ ] Implement documentation updates
- [ ] Implement technical blog post creation
- [ ] Implement citation generation (basic)
- [ ] Implement link building automation (basic)
- [ ] Integrate authority building into campaigns
- [ ] Implement authority score tracking
- [ ] Create authority building LiveView
- [ ] Write tests for Authority Building
- [ ] Create background jobs for authority building

### 13.12 Iteration 8: Consistency Management (Weeks 31-34)

- [ ] Create Consistency Manager Automation module
- [ ] Implement automated consistency fixes
- [ ] Implement message synchronization
- [ ] Implement drift detection and correction
- [ ] Implement consistency monitoring
- [ ] Integrate consistency management into campaigns
- [ ] Create consistency management LiveView
- [ ] Write tests for Consistency Management
- [ ] Create background jobs for consistency management

### 13.13 Iteration 9: Authority Building - Advanced (Weeks 35-38)

- [ ] Implement community engagement automation
  - [ ] Reddit API integration
  - [ ] HackerNews integration
  - [ ] Forum engagement (Discord, industry forums)
  - [ ] Q&A site participation (Stack Overflow, Quora)
- [ ] Implement social media optimization
  - [ ] LinkedIn API integration
  - [ ] Twitter/X API integration
  - [ ] Facebook Business API integration
  - [ ] Social media content posting
- [ ] Implement press release distribution
  - [ ] PR wire service integration
  - [ ] Industry publication targeting
  - [ ] News outlet outreach
- [ ] Implement news/article placement
  - [ ] Guest post placement automation
  - [ ] Industry publication article placement
- [ ] Implement review platform optimization
  - [ ] G2 API integration
  - [ ] Capterra API integration
  - [ ] Trustpilot API integration
  - [ ] Google Business Profile API
- [ ] Implement directory listings
  - [ ] Industry directory submissions
  - [ ] Business listing optimization
  - [ ] Professional association listings
- [ ] Write tests for advanced authority building
- [ ] Create background jobs for advanced authority building

### 13.14 Iteration 10: Full Automation & Campaigns (Weeks 39-42)

- [ ] Create Automation Optimizer module
- [ ] Implement full Campaign Management System
- [ ] Implement campaign optimization
- [ ] Implement automation performance tracking
- [ ] Ensure fully automated execution (no approval workflows)
- [ ] Implement multi-project management
- [ ] Create full automation dashboard
- [ ] Write tests for full automation
- [ ] Create background jobs for all automation workflows

### 13.15 Iteration 11: Polish & Scale (Weeks 43-46)

- [ ] Improve error handling across all modules
- [ ] Add comprehensive logging
- [ ] Optimize database queries
- [ ] Add database indexes
- [ ] Implement caching where appropriate
- [ ] Add rate limiting
- [ ] Improve UI/UX
- [ ] Add loading states
- [ ] Improve error messages
- [ ] Write comprehensive documentation
- [ ] Set up CI/CD pipeline
- [ ] Configure production environment
- [ ] Performance testing
- [ ] Security audit
- [ ] Monitoring and alerting setup
- [ ] Load testing
- [ ] Disaster recovery planning

---

## 14. Database Migrations

### 14.1 Initial Migrations

1. `create_users` - User table
2. `create_companies` - Company table (the client, can also be optimized)
3. `create_roles` - Role table (user-company association)
4. `create_products` - Product table (one type of optimizable entity - includes product_type, category, launch dates)
5. `create_competitor_products` - CompetitorProduct table (competitor products)
6. `add_competitors_to_companies` - Add competitors JSONB array column to companies table
7. `create_projects` - Project table (polymorphic: optimizable_type + optimizable_id, includes project_type, urgency_level)
8. `create_scan_runs` - ScanRun table
9. `create_scan_results` - ScanResult table

### 14.2 GEO Engine Migrations

10. `create_entity_snapshots` - EntitySnapshot table (polymorphic: optimizable_type + optimizable_id)
11. `create_recall_results` - RecallResult table
12. `create_authority_scores` - AuthorityScore table (polymorphic: optimizable_type + optimizable_id)
13. `create_drift_scores` - DriftScore table (polymorphic: optimizable_type + optimizable_id)

### 14.3 Internal Tool Migrations

12. `create_narratives` - Narrative table
13. `create_playbooks` - Playbook table
14. `create_tasks` - Task table

### 14.4 Wiki Migrations (Core Solution)

15. `create_wiki_pages` - WikiPage table
16. `create_wiki_contents` - WikiContent table
17. `create_wiki_platforms` - WikiPlatform table

### 14.5 Automation Migrations

18. `create_campaigns` - Campaign table
19. `create_automation_results` - AutomationResult table
20. `create_content_items` - ContentItem table

### 14.6 Vector Store Migration

21. `enable_pgvector` - Enable pgvector extension
22. `create_embeddings` - Embeddings table with vector column

---

## 15. Configuration

### 15.1 Application Config

```elixir
# config/config.exs
config :thevis, Thevis.Repo,
  database: "thevis_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :thevis, Thevis.AI,
  adapter: Thevis.AI.OpenAIAdapter,
  api_key: System.get_env("OPENAI_API_KEY")

config :thevis, Oban,
  repo: Thevis.Repo,
  queues: [scans: 10, reports: 5, automation: 15, publishing: 10]

config :thevis, Thevis.Geo.Automation,
  fully_automated: true,
  max_content_per_day: 10,
  publishing_rate_limit: 5,
  product_launch_intensity_multiplier: 2.0,  # 2x intensity for product launches
  launch_window_max_content_per_day: 20  # Higher limit during launch windows

config :thevis, Thevis.Wikis,
  wikipedia_api_enabled: true,
  wikipedia_rate_limit: 5,  # requests per minute
  wiki_sync_interval: 3600,  # seconds
  fully_automated: true,
  max_wiki_updates_per_day: 10

config :thevis, Thevis.Billing,
  default_currency: "USD",
  payment_providers: [:stripe, :paypal, :wire_transfer, :manual],
  invoice_due_days: 30,
  auto_renew_enabled: true,
  subscription_expiry_reminder_days: [7, 3, 1],  # Days before expiry to send reminders
  package_discounts: %{
    three_months: 0.0,    # 0% discount
    six_months: 0.10,     # 10% discount
    twelve_months: 0.20   # 20% discount
  }
```

### 15.2 Environment-Specific Config

- `config/dev.exs` - Development settings
- `config/test.exs` - Test settings
- `config/prod.exs` - Production settings

---

## 16. Deployment Considerations

### 16.1 Production Requirements

- PostgreSQL 14+ with pgvector
- Elixir 1.16+ runtime
- Oban Pro (optional, for advanced features)
- Environment variables for secrets
- SSL/TLS for all connections

### 16.2 Monitoring

- Application monitoring (AppSignal/Sentry)
- Database monitoring
- Job queue monitoring
- Error tracking

### 16.3 Scaling Considerations

- Horizontal scaling for LiveView
- Database connection pooling
- Job queue scaling
- Vector store scaling (consider Qdrant for large scale)

---

## 17. Wiki Management Architecture (Core Solution)

### 17.1 Wiki Page Creation Flow

```
Narrative Available
    ↓
Wiki Gap Analysis
    ↓
Content Generation (from narrative)
    ↓
AI Optimization
    ↓
Wikipedia Compliance Check (if applicable)
    ↓
Automated Validation
    ↓
Publishing to Wiki Platform (Fully Automated)
    ↓
Performance Tracking
    ↓
GEO Score Impact Measurement
```

### 17.2 Wiki Content Optimization

**AI Training Signal Optimization:**
1. **Structured Data**: Generate infoboxes, categories, metadata
2. **Comprehensive Coverage**: Ensure all key company details included
3. **Consistent Terminology**: Use narrative-defined terminology
4. **Authority Sources**: Add citations and references
5. **Semantic Markup**: Add semantic HTML and structured data
6. **SEO Optimization**: Optimize for search and AI discovery

**Wikipedia-Specific Optimization:**
1. **Notability Check**: Verify company meets Wikipedia notability guidelines
2. **NPOV Compliance**: Ensure neutral point of view
3. **Reliable Sources**: Include verifiable, reliable sources
4. **Proper Formatting**: Follow Wikipedia style guidelines
5. **Category Placement**: Add appropriate categories
6. **Infobox Generation**: Create Wikipedia-compliant infoboxes

### 17.3 Wiki Platform Integrations

**Wikipedia:**
- Wikipedia API (with rate limiting)
- Manual workflow for complex edits
- Compliance checking before submission
- Edit tracking and monitoring
- Revert detection and alerts

**Company Wikis:**
- Confluence API integration
- Notion API integration
- Custom wiki API support
- Automated updates
- Version control

**Knowledge Bases:**
- Documentation platform APIs
- Automated synchronization
- Multi-platform support

### 17.4 Wiki-Narrative Synchronization

**Automatic Sync:**
- Detect narrative changes
- Identify affected wiki pages
- Generate updated wiki content
- Update wiki pages automatically
- Track sync history

**Manual Sync:**
- Consultant-triggered sync
- Selective page updates
- Bulk update operations

### 17.5 Wiki Performance Tracking

**Metrics:**
- Wiki page views
- Edit frequency
- GEO score correlation
- Recall percentage impact
- Authority score impact
- Time to improvement

**Analytics:**
- Before/after GEO score comparison
- Wiki page contribution to improvements
- ROI measurement
- Performance trends

---

## 18. Automation Architecture Details

### 18.1 Campaign Execution Flow (Wiki-Integrated)

```
Campaign Created
    ↓
Opportunities Identified
    ↓
Content Generation (Automatic)
    ├── Wiki Pages Generated (Primary)
    ├── Wikipedia Pages Generated
    ├── Company Wikis Generated
    └── Other Content Generated
    ↓
Content Optimization (Automatic)
    ├── Wiki Content Optimized for AI
    └── Other Content Optimized
    ↓
Automated Validation
    ↓
Publishing Execution (Automatic)
    ├── Wiki Pages Published
    ├── Wikipedia Published (fully automated)
    ├── Company Wikis Updated
    └── Other Content Published
    ↓
Performance Tracking (Automatic)
    ├── Wiki Performance Tracked
    └── GEO Score Impact Measured
    ↓
Campaign Optimization (Automatic)
    └── Wiki Pages Updated Based on Results
```

### 18.2 Content Generation Pipeline (Wiki-First)

1. **Input**: Narrative, playbook, content type, target platform
2. **Generation**: LLM generates content based on narrative and best practices
   - **Wiki pages generated first** (primary content)
   - **Wikipedia content generated** (if applicable)
   - **Company wiki content generated**
   - Other content types generated
3. **Optimization**: Content optimized for AI training signals
   - **Wiki content optimized for AI training** (structured data, citations, etc.)
   - Other content optimized
4. **Review**: Content reviewed (automated or manual)
   - **All wikis fully automated**
   - Content automatically validated
   - Other content reviewed
5. **Publishing**: Content published to target platform
   - **Wiki pages published automatically**
   - **Wikipedia published** (if approved)
   - **Company wikis updated automatically**
   - Other content published
6. **Tracking**: Performance tracked and measured
   - **Wiki performance tracked**
   - **GEO score impact measured**
   - Other content tracked

### 18.3 Fully Automated Execution (No Approval Workflows)

**Fully Automated (No Approval Required):**
- **All wiki page updates** (Wikipedia, company wikis, all platforms)
- **All content creation** (blog posts, documentation, etc.)
- **All publishing** (all platforms)
- **All consistency fixes**
- **All authority building activities**
- **All campaign executions**
- **All updates and synchronization**

**Automated Validation:**
- Content automatically validated for quality
- Wikipedia compliance automatically checked
- Content automatically optimized before publishing
- All changes automatically logged and tracked

### 18.3.1 Product Launch Campaign Mode

**Product Launch Specific Features:**
- **Higher Intensity**: 2x content generation and publishing frequency
- **Launch Window Awareness**: Campaigns automatically adjust based on launch window dates
- **Urgency-Based Prioritization**: Critical urgency projects get highest priority
- **Rapid Wiki Creation**: Wiki pages created immediately upon campaign start
- **Aggressive Publishing**: Content published as soon as generated (no delays)
- **Launch Window Tracking**: Campaigns automatically pause/complete based on launch window end date

**Product Launch Workflow** (`project_type: :product_launch`):
1. Project identified as product launch type (new product)
2. Launch window dates configured on product
3. Campaign created with `product_launch` type and `critical` intensity
4. Wiki pages generated immediately (highest priority)
5. Content published aggressively (no scheduling delays)
6. Performance tracked daily during launch window
7. Campaign automatically completes or transitions at launch window end

**Ongoing Monitoring Workflow** (`project_type: :ongoing_monitoring`):
1. Project identified as ongoing monitoring type (existing product or company)
2. No launch window (products already in market)
3. Campaign created with `ongoing_monitoring` type and `standard` intensity
4. Wiki pages created/updated at sustainable pace
5. Content published on regular schedule
6. Performance tracked weekly/monthly
7. Campaign continues indefinitely with regular optimization cycles

### 18.4 Platform Integrations (Wiki-First)

**Wiki Platforms (Primary):**
- **Wikipedia**: API integration, fully automated creation/updates
- **Company Wikis**: Confluence, Notion, custom - fully automated
- **Knowledge Bases**: Automated updates and synchronization
- **Documentation Wikis**: Automated maintenance

**Other Platforms:**
- **GitHub**: Repository API integration, README updates, documentation updates
- **Medium**: Publishing API integration, article creation, tag optimization
- **Blog/Website**: CMS API integration (WordPress, Contentful, etc.), article publishing, SEO optimization
- **Documentation Sites**: Documentation platform APIs, automated updates, version control integration

**Wiki Integration Priority:**
- Wiki platforms are prioritized in automation workflows
- Wiki pages are created first in campaigns
- Wiki updates take precedence in consistency management
- Wiki performance is primary metric for authority building

---

## 19. Non-Goals (V1)

- Multi-LLM benchmarking UI
- Self-serve optimization tools (client-facing)
- Client-visible automation controls
- Real-time monitoring dashboard (client-facing)
- API access for external clients
- Mobile applications
- White-label solutions

---

## 20. Future Enhancements

- Multi-LLM support and comparison
- Real-time monitoring capabilities
- Advanced analytics and ML
- Integration with marketing tools (HubSpot, Salesforce)
- Advanced AI-powered content generation
- Predictive analytics for GEO improvements
- Automated competitor displacement strategies
- Social media automation
- Email marketing integration
- Advanced A/B testing for content
- API access for enterprise clients
- Advanced visualization and dashboards
- Machine learning for campaign optimization

