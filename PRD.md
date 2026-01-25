# Product Requirements Document (PRD)
## thevis.ai

**Version:** 1.0  
**Date:** 2024  
**Product:** thevis  
**Domain:** thevis.ai

---

## 1. Product Vision

thevis helps companies ensure that generative AI systems correctly understand, describe, and recommend their **products and services**. We optimize based on company type and search intent.

**Core Solution: AI Visibility Optimization**

thevis optimizes AI visibility through multiple techniques including wiki page creation and optimization, content automation, authority building, and consistency management. Wiki pages are a primary training signal for AI systems, so we use automated wiki page creation and maintenance as one of our key optimization techniques.

**What We Optimize - Based on Company Type:**

**Service-Based Companies:**
- Optimize the **company itself** (the service)
- Example: "best company for visa assistance" → Optimize the visa assistance company
- Example: "best accounting software company" → Optimize the SaaS company
- Example: "best consulting firm" → Optimize the consulting company
- **Monetization**: Per service (per company)

**Product-Based Companies:**
- Optimize **products** (not the company)
- Optimize all products in a category together
- Example: "best skincare products" → Optimize all skincare products from the company
- Example: "best chocolate bars" → Optimize all chocolate products from the company
- Example: "best running shoes" → Optimize all footwear products from the company
- **Monetization**: Per product (or per product category)

**Key Distinction:**
- **Service Company** = Company IS the product (e.g., visa assistance service, consulting firm)
- **Product Company** = Company makes products (e.g., cosmetics company, food brand)
- We optimize the entity that matches search intent (service vs product)

**Primary Market: Product & Service Optimization**
Our main clients are:

**Product-Based Companies:**
1. **New Product Launches**—Companies launching new products (cosmetics, edibles, sweets, D2C brands, consumer products) who need to establish AI visibility quickly during their launch window
2. **Existing Products**—Companies with existing products in market who need ongoing optimization to maintain and improve AI visibility
3. **Product Categories**—Optimize all products in a category together (e.g., all skincare products, all chocolate products)

**Service-Based Companies:**
4. **Service Optimization**—Service companies, SaaS providers, consulting firms, agencies who need to be recommended when people search for services (e.g., "best company for visa assistance", "best accounting software company", "best consulting firm")

This is achieved through:
- **AI Probing**: Systematic testing of how AI systems recognize and describe products and companies
- **Recall Measurement**: Quantifying whether AI recommends products or companies for relevant prompts
- **Authority Analysis**: Identifying training signals and authority sources for products and companies
- **Automated Optimization**: AI-powered automation to improve product and company presence and visibility
  - Wiki page creation and optimization (primary training signal for AI)
  - Content automation (blog posts, documentation, GitHub READMEs)
  - Authority building (citations, links, references, press releases, news placement)
  - Link building (outreach, backlink acquisition, relationship building)
  - Community engagement (Reddit, HackerNews, forums, Q&A sites)
  - Social media optimization (LinkedIn, Twitter/X, Facebook business pages)
  - Review platform optimization (G2, Capterra, Trustpilot, Google Reviews)
  - Directory listings (industry directories, business listings)
  - Consistency management (synchronized messaging across platforms)
- **Consultant-Led Strategy**: Expert-driven strategies with automated execution

**End State:** thevis becomes the system of record for how AI systems perceive products and companies. Automated optimization techniques (including wiki page management) drive GEO improvements. Consulting is the revenue engine. Automation is the multiplier that enables consultants to efficiently drive GEO improvements for all clients.

---

## 2. Target Users

### 2.1 Primary Users

**Consultants (Internal or Partner)**
- Execute GEO strategies
- Use internal tools for opportunity detection
- Build narratives and playbooks
- Manage execution plans
- Access tactical recommendations

### 2.2 Paying Customers

**Product-Based Companies (Primary Market)**

**New Product Launches:**
- **Consumer Products**: Cosmetics, skincare, beauty products launching to market
- **Food & Beverage**: Edibles, sweets, snacks, specialty food products
- **D2C Brands**: Direct-to-consumer brands across all categories
- **CPG Products**: Consumer packaged goods entering new markets
- **Fashion & Apparel**: New clothing lines, accessories, lifestyle brands
- **Health & Wellness**: Supplements, wellness products, fitness brands
- Critical need: Establish product presence in AI systems before competitors
- Launch window: Must build AI visibility quickly during product launch phase
- Budget allocation: Marketing budgets allocated to brand awareness and discovery
- **Monetization**: Per product

**Existing Products:**
- Products already in market that need ongoing optimization
- Products losing visibility in AI recommendations
- Products competing with new entrants
- Products needing to maintain market position
- Products expanding to new markets or categories
- **Product Categories**: Optimize all products in a category together (e.g., all skincare products from a company)
- Use case: Maintain and improve AI visibility for established products
- Ongoing monitoring and optimization to stay competitive
- **Monetization**: Per product (or per product category if optimizing category together)

**Service-Based Companies (Primary Market)**
- **Service Companies**: Visa assistance, immigration services, consulting firms
- **SaaS Companies**: B2B SaaS providers (the service IS the product)
- **Professional Services**: Law firms, accounting firms, agencies
- **B2B Service Providers**: Companies that provide services (not physical products)
- Use case: "Which is the best company for visa assistance?" → Optimize the service company itself
- Use case: "Best accounting software company" → Optimize the SaaS company itself
- Need: Ensure AI systems recommend the company (the service) for relevant queries
- **Monetization**: Per service (per company)

**Developer Tool Companies**
- Companies building developer-focused products
- Critical to be discoverable in AI coding assistant recommendations

**Funded Startups (Series A+)**
- Companies with brand recognition goals
- Need to measure and improve AI visibility (both product and company level)
- Have budget for consulting services

---

## 3. Core Use Cases

### 3.1 Client Use Cases

1. **Understand Current AI Perception**
   - See how AI systems currently describe the product
   - View AI-generated product descriptions
   - Understand gaps in AI understanding of the product

2. **Measure AI Recommendation Performance**
   - Track recall percentage for relevant product-related prompts
   - Monitor first mention rank when product is recommended
   - Compare against competitor products

3. **Track Visibility Over Time**
   - Historical progress tracking for product visibility
   - GEO Score trends for the product
   - Recall performance charts
   - Definition accuracy improvements

4. **Identify Authority and Consistency Gaps**
   - View authority scores for the product
   - Understand consistency issues in product descriptions
   - See drift scores across sources

5. **Export Audit Reports**
   - Generate PDF audit reports for the product
   - Share findings with stakeholders
   - Track progress across audits

### 3.2 Consultant Use Cases

1. **Detect Optimization Opportunities**
   - Use opportunity detection engine
   - Identify quick wins
   - Prioritize high-impact actions

2. **Execute GEO Strategies**
   - Access playbook engine
   - Build custom narratives
   - Create execution plans

3. **Manage Client Projects**
   - View all client projects
   - Track scan results
   - Monitor progress

4. **Execute Tactical Recommendations**
   - Access consultant task board
   - Follow playbook recommendations
   - Track execution status

5. **Automate GEO Improvements**
   - Enable automated optimization campaigns
   - Monitor automated content creation
   - Review and approve automated actions
   - Track automation effectiveness

6. **Manage Wiki Pages**
   - Create and optimize wiki pages (Wikipedia, company wikis)
   - Automate wiki page creation and updates
   - Monitor wiki page performance
   - Track wiki page impact on GEO scores

---

## 4. Product Boundaries (Critical)

### 4.1 What Clients See

✅ **Visible to Clients:**
- GEO Score (overall AI visibility metric)
- AI-generated company description (read-only)
- Recall performance charts
- Historical progress tracking
- Authority scores (high-level)
- Exportable audit reports (PDF)

### 4.2 What Clients Do NOT See

❌ **Hidden from Clients:**
- Tactical recommendations
- Playbooks
- Publishing strategies
- Narrative rules
- Opportunity detection details
- Execution plans
- Internal consultant tools

**Rationale:** This ensures consulting moat. Clients understand their current state and progress, but optimization strategies remain consultant-led.

---

## 5. Core Features

### 5.1 Client-Facing Features

#### 5.1.1 Company & Product/Service Onboarding
**Description:** Initial setup based on company type (product-based vs service-based)  
**User Flow:**

**For Product-Based Companies:**
1. Consultant creates company profile (the client)
2. Enter company name, domain, industry (product-based)
3. Determine optimization approach:
   - **Individual Products**: Create product profile(s) - optimize each product separately
   - **Product Category**: Group products by category - optimize all products in category together
4. For each product (or product category):
   - **New Product**: Enter product name, description, category, launch date, launch window
   - **Existing Product**: Enter product name, description, category, current market status
5. Add competitor products for comparison
6. Configure initial scan parameters for products
7. Trigger first GEO audit for products

**For Service-Based Companies:**
1. Consultant creates company profile (the client)
2. Enter company name, domain, industry (service-based)
3. Mark company as service-based (company IS the service)
4. Enter service description, value proposition, target market
5. Add competitor service companies for comparison
6. Configure initial scan parameters for the service (company)
7. Trigger first GEO audit for the service (company)

**Acceptance Criteria:**
- Company profile can be created with company type (product-based vs service-based)
- Product profile(s) can be created for product-based companies
- Products can be grouped by category for category-level optimization
- Service-based companies can be marked for service optimization
- Competitor products (for product companies) or competitor services (for service companies) can be added
- Initial scan can be triggered for products or services
- Products or services appear in client dashboard

#### 5.1.2 GEO Audit Dashboard
**Description:** Main client-facing dashboard showing current AI visibility state for the product  
**Components:**
- GEO Score (primary metric) for the product
- AI-generated product description
- Key metrics overview:
  - Recall Percentage (for product-related prompts)
  - First Mention Rank (when product is mentioned)
  - Definition Accuracy (how accurately AI describes the product)
  - Competitor Displacement (vs. competitor products)
- Recent scan results for the product
- Quick insights about product visibility

**Acceptance Criteria:**
- Dashboard loads with latest scan data
- GEO Score is prominently displayed
- All key metrics are visible
- Data updates after new scans

#### 5.1.3 Recall Visibility Report
**Description:** Detailed report on AI recommendation performance  
**Components:**
- Recall percentage by category
- First mention rank trends
- Competitor comparison
- Prompt category breakdown
- Historical recall data

**Acceptance Criteria:**
- Report shows recall data from latest scan
- Historical comparison is available
- Competitor data is included
- Data can be filtered by category

#### 5.1.4 Historical Progress Tracking
**Description:** Track changes in AI visibility over time  
**Components:**
- GEO Score trend chart
- Recall percentage over time
- Definition accuracy trends
- Authority score changes
- Timeline of scans

**Acceptance Criteria:**
- Charts display historical data
- Multiple metrics can be viewed
- Time range can be adjusted
- Data points are clickable for details

#### 5.1.5 Exportable Audit Report (PDF)
**Description:** Professional PDF report for stakeholders  
**Components:**
- Executive summary
- GEO Score and key metrics
- AI-generated description
- Recall analysis
- Authority insights
- Historical trends
- Recommendations summary (high-level only)

**Acceptance Criteria:**
- PDF can be generated on-demand
- Report includes all key metrics
- Professional formatting
- Can be downloaded and shared

### 5.2 Internal / Consultant Features

#### 5.2.1 Opportunity Detection Engine
**Description:** Identify optimization opportunities automatically  
**Components:**
- Gap analysis
- Quick win identification
- Priority scoring
- Opportunity categorization
- Impact estimation

**Acceptance Criteria:**
- Engine analyzes scan results
- Opportunities are ranked by impact
- Categories are clearly defined
- Can be filtered and sorted

#### 5.2.2 Playbook Engine
**Description:** Structured optimization strategies  
**Components:**
- Playbook library
- Playbook selection logic
- Custom playbook creation
- Playbook effectiveness tracking
- Template system

**Acceptance Criteria:**
- Playbooks can be selected for projects
- Custom playbooks can be created
- Playbook recommendations are shown
- Effectiveness can be tracked

#### 5.2.3 Narrative Builder
**Description:** Build and refine company narratives  
**Components:**
- Narrative editor
- Narrative rules engine
- Version control
- A/B testing support
- Effectiveness measurement

**Acceptance Criteria:**
- Narratives can be created and edited
- Rules can be defined
- Versions are tracked
- Can be tested and measured

#### 5.2.4 Execution Planner
**Description:** Create and manage execution plans  
**Components:**
- Plan builder
- Task generation
- Timeline estimation
- Resource allocation
- Progress tracking

**Acceptance Criteria:**
- Plans can be created from opportunities
- Tasks are automatically generated
- Timeline is estimated
- Progress can be tracked

#### 5.2.5 Consultant Task Board
**Description:** Manage consultant workflow  
**Components:**
- Task list by project
- Priority indicators
- Status tracking
- Assignment system
- Due dates
- Completion tracking

**Acceptance Criteria:**
- Tasks are visible by project
- Can be filtered and sorted
- Status can be updated
- Assignments can be made

#### 5.2.6 Automated Optimization Engine
**Description:** Automatically execute strategies to improve AI presence  
**Components:**
- Campaign management
- Automated content creation
- **Automated wiki page creation and management** (core)
- Automated publishing workflows
- Authority building automation
- Consistency improvement automation
- Performance tracking

**Acceptance Criteria:**
- Campaigns can be created and configured
- Content is automatically generated based on narratives
- **Wiki pages are automatically created from narratives**
- **Wiki pages are automatically updated when narratives change**
- **Wikipedia pages are created/updated automatically**
- **Company wikis are automatically maintained**
- Publishing workflows execute automatically
- Authority building activities run on schedule
- Consistency improvements are applied automatically
- All automated actions are tracked and measurable
- All actions are fully automated

#### 5.2.7 Content Automation Engine
**Description:** Automatically create and optimize content for AI training  
**Components:**
- Content generation (blog posts, docs, GitHub READMEs, **wiki pages**)
- **Wiki page generation and optimization** (one of the content optimization techniques)
- Content optimization for AI training
- Multi-platform publishing (**including Wikipedia and company wikis**)
- Content scheduling
- A/B testing for content effectiveness
- Content performance tracking

**Acceptance Criteria:**
- Content is generated from narratives and playbooks
- **Wiki pages are generated as part of content optimization strategy**
- **Wikipedia-compliant content is generated as part of authority building**
- Content is optimized for AI training signals
- Can publish to multiple platforms (GitHub, Medium, company blog, **Wikipedia, company wikis**)
- Content can be scheduled
- Content effectiveness is measured
- Generated content can be reviewed before publishing
- **Wiki pages are synchronized with narrative changes as part of consistency optimization**

#### 5.2.8 Authority Building Automation
**Description:** Automatically build authority signals across platforms  
**Components:**
- **Wiki page creation and optimization** (primary authority signal)
- **Wikipedia page management** (high authority signal)
- GitHub repository optimization
- Documentation site updates
- Technical blog post creation
- **Citation generation and placement** (comprehensive citation strategy)
- **Link building automation** (outreach, relationship building, backlink acquisition)
- **Community engagement automation** (Reddit, HackerNews, Discord, forums, Q&A sites)
- **Social media optimization** (LinkedIn, Twitter/X, Facebook business pages)
- **Press release distribution** (PR wire services, industry publications)
- **News/article placement** (guest posts, industry publications, news sites)
- **Review platform optimization** (G2, Capterra, Trustpilot, Google Reviews)
- **Directory listings** (industry directories, business listings, professional associations)
- Authority score tracking

**Acceptance Criteria:**
- **Wiki pages are automatically created to build authority**
- **Wikipedia pages are created/updated automatically**
- **Company wikis are automatically maintained**
- GitHub repositories are automatically optimized
- Documentation is kept up-to-date
- Technical content is created and published
- **Citations are generated and placed across authoritative sources**
- **Link building campaigns are executed automatically**
- **Community engagement activities are automated (where possible)**
- **Social media profiles are optimized and content is posted**
- **Press releases are distributed to relevant outlets**
- **News articles and guest posts are placed in target publications**
- **Review platforms are optimized and monitored**
- **Directory listings are created and maintained**
- Authority signals are tracked
- Improvements in authority scores are measurable
- **Wiki pages contribute significantly to authority scores**

#### 5.2.9 Consistency Automation
**Description:** Automatically ensure consistent messaging across all sources  
**Components:**
- Message synchronization
- Automated updates across platforms
- Drift detection and correction
- Consistency monitoring
- Automated fixes for inconsistencies

**Acceptance Criteria:**
- Messaging is synchronized across platforms
- Inconsistencies are detected automatically
- Fixes are applied automatically
- Consistency scores improve over time
- All changes are tracked and auditable

#### 5.2.10 Wiki Page Management (Optimization Technique)
**Description:** Wiki page creation and optimization is one of the optimization techniques used in automated campaigns  
**Note:** Wiki management is integrated into the Automated Optimization Engine as an optimization technique, not a separate feature. Wiki pages are created and optimized as part of the overall optimization strategy.

**Wiki Page Optimization Techniques:**
- **Creation**: Wiki pages created from narratives during campaigns (as part of content optimization)
- **Updates**: Wiki pages updated when narratives change (as part of consistency optimization)
- **Wikipedia Management**: Wikipedia pages created/updated (as part of authority building)
- **Company Wiki Management**: Company wikis maintained and synchronized (as part of consistency optimization)
- **Content Optimization**: Wiki content optimized for AI training signals
- **Performance Tracking**: Wiki page impact tracked and measured (as part of campaign metrics)
- **Multi-Platform Sync**: Wiki pages synchronized across platforms (as part of consistency management)

**Integration as Optimization Technique:**
- Wiki creation is part of content optimization workflow
- Wiki updates are part of consistency optimization
- Wiki management is part of authority building optimization
- Wiki performance is tracked as part of campaign metrics

---

## 6. Key Metrics

### 6.1 Primary Metrics

**GEO Score**
- Overall AI visibility metric (0-100)
- Composite of multiple factors
- Primary KPI for clients

**Recall Percentage**
- Percentage of relevant prompts where company is mentioned
- Measured across multiple prompt categories
- Key indicator of AI visibility

**First Mention Rank**
- Average position when company is mentioned
- Lower is better
- Indicates prominence in AI responses

**Definition Accuracy**
- How accurately AI describes the company
- Measured against ground truth
- Indicates quality of AI understanding

**Competitor Displacement**
- Frequency of being mentioned instead of competitors
- Indicates competitive positioning
- Measured in head-to-head comparisons

### 6.2 Secondary Metrics

- Authority Score
- Consistency Score
- Drift Score
- Scan Frequency
- Improvement Rate

### 6.3 Automation Metrics

- **Automation Effectiveness**: Improvement rate from automated actions
- **Content Performance**: Engagement and AI training signal strength
- **Campaign Success Rate**: Percentage of successful automation campaigns
- **Time to Improvement**: How quickly GEO scores improve with automation
- **Automation ROI**: Cost savings vs manual execution

---

## 7. Monetization Strategy

### 7.1 Pricing Model: Per Product or Per Service

**Core Principle:** Charge per entity optimized based on company type
- **Product-Based Companies**: Charge per product (or per product category if optimizing category together)
- **Service-Based Companies**: Charge per service (the company itself is the service)
- Companies can have multiple products/services

**Rationale:**
- **Product Companies**: Value is delivered per product optimized
  - Can optimize individual products or product categories together
  - Example: Cosmetics company with 10 skincare products → Charge per product (or per category if grouping)
- **Service Companies**: Value is delivered per service (company)
  - The company IS the service, so charge per company
  - Example: Visa assistance company → Charge per service (1 service = 1 company)
- Different project types have different costs (launch vs ongoing)
- Automation scales, but consultant time is per product/service
- Allows companies to start with one product/service and expand

### 7.2 Revenue Streams

#### 7.2.1 GEO Audit (One-time, Per Product or Per Service)
**Purpose:** Initial assessment and baseline establishment

**Pricing:**
- **Product Audit**: $300 - $500 per product
  - For product-based companies
  - Can audit individual products or product categories
- **Service Audit**: $400 - $600 per service
  - For service-based companies (company IS the service)
  - One audit per service company
- Includes: Full scan, GEO score baseline, opportunity analysis, PDF report

**Cost Structure:**
- LLM API costs: $5-15 per audit
- Infrastructure: $2-5 per audit
- Consultant time (2-3 hours): $200-300 per audit
- Total cost: $207-320 per audit
- Pricing ensures 25% margin target

**When:** Required before starting any optimization project

#### 7.2.2 Product Launch Packages (Time-bound, Per Product)
**Purpose:** Intensive support for new product launches

**Pricing Structure:**
- **3-Month Launch Package**: $5,000 - $8,000 per product
- **6-Month Launch Package**: $9,000 - $15,000 per product
- **Premium Launch Package** (with dedicated consultant): $12,000 - $20,000 per product

**Includes:**
- Rapid wiki page creation and optimization
- Aggressive content automation (2x intensity)
- Daily/weekly scans during launch window
- Higher-touch consultant engagement
- Priority support
- Launch window deadline awareness

**Cost Structure (3-month package):**
- LLM API costs: $200-400/month = $600-1,200 total
- Infrastructure: $5-10/month = $15-30 total
- Other services: $30-60/month = $90-180 total
- Consultant time (10-15 hrs/month @ $100/hr): $1,000-1,500/month = $3,000-4,500 total
- Total cost: $3,705-5,910 for 3 months
- Pricing ensures 25-35% margin target

**Payment:** Upfront or 50% upfront + 50% at launch window end

#### 7.2.3 Ongoing Product Optimization (Package Pricing, Per Product)
**Purpose:** Sustainable optimization for existing products

**Package Pricing Structure:**

| Tier | 3 Months | 6 Months | 12 Months |
|------|----------|----------|-----------|
| **Starter** | $600 - $1,200 | $1,080 - $2,160 | $1,920 - $3,840 |
| **Professional** | $1,500 - $2,100 | $2,700 - $3,780 | $4,800 - $6,720 |
| **Enterprise** | $2,400 - $3,900 | $4,320 - $7,020 | $7,680 - $12,480 |

**Package Details:**

**Starter Package:**
- Weekly scans
- Monthly wiki optimization
- Quarterly consultant review
- Standard automation pace
- **3 months**: $600-1,200 (equivalent to $200-400/month)
- **6 months**: $1,080-2,160 (10% discount, $180-360/month)
- **12 months**: $1,920-3,840 (20% discount, $160-320/month)

**Professional Package:**
- Bi-weekly scans
- Bi-weekly wiki optimization
- Monthly consultant review
- Enhanced automation
- Priority support
- **3 months**: $1,500-2,100 (equivalent to $500-700/month)
- **6 months**: $2,700-3,780 (10% discount, $450-630/month)
- **12 months**: $4,800-6,720 (20% discount, $400-560/month)

**Enterprise Package:**
- Weekly scans
- Weekly wiki optimization
- Bi-weekly consultant review
- Maximum automation
- Dedicated consultant access
- **3 months**: $2,400-3,900 (equivalent to $800-1,300/month)
- **6 months**: $4,320-7,020 (10% discount, $720-1,170/month)
- **12 months**: $7,680-12,480 (20% discount, $640-1,040/month)

**Cost Structure:**
- **Starter**: LLM ($20-30) + Infrastructure ($5-10) + Services ($10-20) + Consultant ($100-200) = $135-260/month cost
- **Professional**: LLM ($25-40) + Infrastructure ($5-10) + Services ($15-30) + Consultant ($300-400) = $345-480/month cost
- **Enterprise**: LLM ($40-60) + Infrastructure ($5-10) + Services ($20-50) + Consultant ($500-800) = $565-920/month cost

**Payment:** Upfront payment for selected package duration. Discounts apply for longer commitments.

#### 7.2.4 Service Optimization (Package Pricing, Per Service)
**Purpose:** Service-level visibility optimization (for service-based companies)

**Package Pricing Structure:**

| Tier | 3 Months | 6 Months | 12 Months |
|------|----------|----------|-----------|
| **Starter** | $900 - $1,500 | $1,620 - $2,700 | $2,880 - $4,800 |
| **Professional** | $1,800 - $2,700 | $3,240 - $4,860 | $5,760 - $8,640 |
| **Enterprise** | $3,000 - $4,800 | $5,400 - $8,640 | $9,600 - $15,360 |

**Package Details:**

**Starter Package:**
- Weekly scans
- Monthly wiki optimization
- Quarterly consultant review
- Standard automation pace
- **3 months**: $900-1,500 (equivalent to $300-500/month)
- **6 months**: $1,620-2,700 (10% discount, $270-450/month)
- **12 months**: $2,880-4,800 (20% discount, $240-400/month)

**Professional Package:**
- Bi-weekly scans
- Bi-weekly wiki optimization
- Monthly consultant review
- Enhanced automation
- Priority support
- **3 months**: $1,800-2,700 (equivalent to $600-900/month)
- **6 months**: $3,240-4,860 (10% discount, $540-810/month)
- **12 months**: $5,760-8,640 (20% discount, $480-720/month)

**Enterprise Package:**
- Weekly scans
- Weekly wiki optimization
- Bi-weekly consultant review
- Maximum automation
- Dedicated consultant access
- **3 months**: $3,000-4,800 (equivalent to $1,000-1,600/month)
- **6 months**: $5,400-8,640 (10% discount, $900-1,440/month)
- **12 months**: $9,600-15,360 (20% discount, $800-1,280/month)

**Cost Structure:**
- Services typically require 20-30% more consultant time than products
- **Starter**: ~$160-320/month cost
- **Professional**: ~$420-600/month cost
- **Enterprise**: ~$700-1,200/month cost

**Payment:** Upfront payment for selected package duration. Discounts apply for longer commitments.

**Note:** For service-based companies, the company IS the service, so this is per company (1 service = 1 company)

#### 7.2.5 Multi-Product/Service Discounts (Company-Level)
**Purpose:** Encourage companies to optimize multiple products/services

**Discount Structure:**
- **2-3 Products/Services**: 5% discount on all products/services
- **4-5 Products/Services**: 10% discount on all products/services
- **6+ Products/Services**: 15% discount on all products/services

**Rationale:** With 25% margin target, discounts are more conservative to maintain profitability while still encouraging portfolio optimization.

**Examples:**
- **Product Company**: 5 skincare products = 5 products, all get 10% discount
- **Product Company**: 3 product categories (skincare, makeup, haircare) = 3 categories, all get 5% discount
- **Service Company**: Typically 1 service (company IS the service), so no discount unless multiple service lines
- Encourages portfolio optimization for product companies

#### 7.2.6 Monitoring-only SaaS (Future - Self-Serve)
**Purpose:** Lower-cost option for companies that don't need consulting

**Pricing:**
- **Basic**: $150 - $250/month per project
  - Automated scans (weekly)
  - Dashboard access
  - Basic reports
  - No consultant access
  - Limited automation

- **Pro**: $400 - $600/month per project
  - Automated scans (bi-weekly)
  - Enhanced dashboard
  - Advanced reports
  - Email support
  - Standard automation

**Cost Structure:**
- No consultant time, so costs are lower ($50-150/month)
- **Basic**: LLM ($20-30) + Infrastructure ($5-10) + Services ($10-20) = $35-60/month cost → $150-250 price (60-75% margin)
- **Pro**: LLM ($25-40) + Infrastructure ($5-10) + Services ($15-30) = $45-80/month cost → $400-600 price (80-85% margin)

### 7.3 Pricing Strategy Rationale

**Margin Target: 25%**
- All pricing is calculated to ensure minimum 25% margin after all costs
- Costs include: LLM API usage, infrastructure, third-party services, and consultant time
- Pricing is reviewed regularly as costs and automation efficiency change

**Why Per Product or Per Service (Not Per Company):**
1. **Value Alignment**: Value is delivered per entity optimized
   - Product companies: Value per product optimized
   - Service companies: Value per service (company) optimized
2. **Scalability**: Companies can start small (1 product/service) and expand
3. **Fair Pricing**: 
   - Product companies with 10 products pay more than companies with 1 product
   - Service companies typically have 1 service (the company itself)
4. **Flexibility**: Product companies can optimize some products but not others

**Why Different Pricing for Project Types:**
1. **Product Launch**: Higher intensity, more consultant time, time-sensitive → Premium pricing
2. **Ongoing Monitoring**: Sustainable pace, predictable costs → Lower pricing
3. **Service Optimization**: Typically more complex than individual products → Slightly higher pricing

**Product Category Optimization:**
- Companies can optimize all products in a category together
- Pricing can be per category (slightly higher than single product) or per product in category
- Example: "All skincare products" optimized together as one project

**Why Multi-Project Discounts:**
1. **Encourages Portfolio Optimization**: Companies optimize all products
2. **Increases LTV**: More projects = higher total revenue
3. **Reduces Churn**: More projects = stickier relationship
4. **Operational Efficiency**: Multiple projects from same company = efficiency gains

### 7.4 Revenue Projections (Example)

**Scenario 1: Product Launch Company**
- 1 new product launch (6-month package): $9,000 - $15,000
- 1 GEO audit: $300 - $500
- **Total First Year**: $9,300 - $15,500

**Scenario 2: Existing Product Company**
- 2 existing products (Professional tier): $500-700/month × 2 = $1,000-1,400/month
- 2 GEO audits: $300-500 × 2 = $600-1,000
- **Total First Year**: $12,600-17,800 (with 5% multi-project discount: $11,970-16,910)

**Scenario 3: Service Company Optimization**
- 1 service optimization (Professional tier): $600-900/month
- 1 GEO audit: $400-600
- **Total First Year**: $7,600-11,400

**Scenario 4: Product Company - Multiple Products**
- 1 product launch (3-month): $5,000-8,000
- 2 existing products (Starter tier): $200-400/month × 2 = $400-800/month
- Multi-product discount (3 products): 5%
- **Total First Year**: $5,000-8,000 + ($400-800 × 12 × 0.95) = $9,560-17,120

**Scenario 5: Product Company - Category Optimization**
- 3 product categories (Professional tier): $500-700/month × 3 = $1,500-2,100/month
- Multi-category discount (3 categories): 5%
- **Total First Year**: ($1,500-2,100 × 12 × 0.95) = $17,100-23,940

### 7.5 Future Pricing Tiers (Self-Serve)

**Starter** ($150-250/month per project):
- Basic monitoring
- Automated scans (weekly)
- Dashboard access
- No consultant access

**Professional** ($400-600/month per project):
- Enhanced monitoring
- Automated scans (bi-weekly)
- Advanced dashboard
- Email support
- Limited automation

**Enterprise** (Custom pricing):
- Full consulting + unlimited scans
- Dedicated consultant
- Custom automation
- Priority support

---

## 8. Success Criteria

### 8.1 Product Success Metrics

- Client GEO Score improvements
- Recall percentage increases
- Client retention rate
- Consultant efficiency gains
- Time to value for new clients

### 8.2 Business Success Metrics

- Revenue per client
- Client acquisition cost
- Consultant utilization
- Average contract value
- Net revenue retention

---

## 9. Wiki Page Management (Optimization Technique)

### 9.1 Overview

Wiki pages are a primary training signal for AI systems. As part of our optimization strategy, thevis automates the creation, optimization, and maintenance of wiki pages for **products and services**:

1. **Creation**: Automatically create wiki pages for products from product narratives
2. **Optimization**: Optimize wiki content specifically for AI training signals about the product
3. **Maintenance**: Automatically update wiki pages as product narratives evolve
4. **Tracking**: Measure wiki page impact on product GEO scores and AI visibility

### 9.2 Wiki Page Types

**Wikipedia Pages**
- Create new Wikipedia pages for companies
- Update existing Wikipedia pages
- Maintain Wikipedia compliance (notability, sources, NPOV)
- Fully automated Wikipedia management
- Track Wikipedia page performance

**Company Wikis**
- Internal company wikis
- Knowledge bases (Confluence, Notion, etc.)
- Documentation wikis
- Developer wikis

**Industry Wikis**
- Industry-specific wikis
- Technical wikis
- Community wikis

### 9.3 Wiki Page Workflow

1. **Analysis**: Analyze current wiki presence and gaps
2. **Creation**: Generate wiki page content from narratives
3. **Optimization**: Optimize content for AI training signals
4. **Review**: Automated validation and optimization
5. **Publishing**: Publish to target wiki platform
6. **Monitoring**: Track wiki page performance
7. **Maintenance**: Automatically update as narratives change

### 9.4 Wiki Content Optimization

**AI Training Signal Optimization:**
- Structured data (infoboxes, categories)
- Comprehensive coverage of company details
- Consistent terminology and messaging
- Authority sources and citations
- Semantic markup and metadata

**Wikipedia-Specific:**
- Notability compliance
- Neutral point of view (NPOV)
- Reliable sources
- Proper formatting and structure
- Category placement

### 9.5 Wiki Page Management as Optimization Technique

**Wiki Page Creation (Optimization Technique):**
- Generate wiki page drafts from narratives (as part of content optimization)
- Create Wikipedia-compliant content (as part of authority building)
- Generate infoboxes and structured data (as part of AI training signal optimization)
- Create citations and references (as part of authority building)

**Wiki Page Updates (Optimization Technique):**
- Sync wiki pages with narrative changes (as part of consistency optimization)
- Update company/product information automatically (as part of consistency management)
- Maintain consistency across wiki platforms (as part of consistency optimization)
- Handle version control and edit history

**Wiki Page Monitoring (Optimization Technique):**
- Track wiki page views and engagement (as part of performance measurement)
- Monitor for vandalism or incorrect edits (as part of quality assurance)
- Alert on significant changes (as part of monitoring)
- Measure impact on GEO scores (as part of optimization effectiveness tracking)

---

## 10. Automation Features (Core Differentiator)

### 10.1 Automated Content Creation

**Purpose:** Automatically generate and publish content that improves AI visibility

**Capabilities:**
- Generate blog posts from narratives
- Create GitHub READMEs optimized for AI
- Generate documentation pages
- Create technical articles
- Optimize existing content for AI training

**Workflow:**
1. System analyzes current GEO state
2. Identifies content gaps
3. Generates content based on narratives and playbooks
4. Optimizes content for AI training signals
5. Publishes to appropriate platforms
6. Tracks performance and iterates

### 10.2 Automated Publishing Workflows

**Purpose:** Automatically publish content across multiple platforms

**Supported Platforms:**
- GitHub (repositories, READMEs, documentation)
- Medium (technical blog posts)
- Company blog/website
- Documentation sites
- Developer communities

**Features:**
- Multi-platform publishing
- Scheduled publishing
- Format conversion (Markdown to HTML, etc.)
- SEO optimization
- AI training signal optimization

### 10.3 Automated Authority Building

**Purpose:** Systematically build authority signals that AI systems recognize

**Activities:**
- GitHub repository optimization
- Documentation site improvements
- Technical content creation
- **Citation generation and placement**
  - Academic citations
  - News article citations
  - Industry publication citations
  - Wikipedia citations
  - Cross-platform citation strategy
- **Link building automation**
  - Backlink outreach campaigns
  - Relationship building with publishers
  - Guest post placement
  - Resource page link building
  - Broken link building
  - Link reclamation
- **Community engagement automation**
  - Reddit participation (relevant subreddits)
  - HackerNews submissions and comments
  - Discord/community forum engagement
  - Q&A site participation (Stack Overflow, Quora)
  - Industry forum engagement
- **Social media optimization**
  - LinkedIn company page optimization
  - Twitter/X profile optimization
  - Facebook business page optimization
  - Social media content posting
  - Profile completeness and optimization
- **Press release distribution**
  - PR wire service distribution
  - Industry publication targeting
  - News outlet outreach
  - Press release optimization for AI training
- **News/article placement**
  - Guest post placement
  - Industry publication articles
  - News site coverage
  - Thought leadership content
- **Review platform optimization**
  - G2 profile optimization
  - Capterra profile optimization
  - Trustpilot profile optimization
  - Google Business Profile optimization
  - Review response automation
- **Directory listings**
  - Industry directory submissions
  - Business listing optimization
  - Professional association listings
  - Niche directory placement

**Tracking:**
- Authority score improvements
- Source count increases
- Citation frequency
- Link quality metrics
- Backlink count and quality
- Social media engagement metrics
- Review platform visibility
- Directory listing coverage

### 10.4 Automated Consistency Management

**Purpose:** Ensure consistent messaging across all sources automatically

**Capabilities:**
- Detect messaging drift
- Synchronize descriptions across platforms
- Update outdated information
- Maintain narrative consistency
- Fix inconsistencies automatically

**Fully Automated:**
- All changes execute automatically
- No approval workflows required
- All changes are logged and auditable

### 10.5 Campaign Management

**Purpose:** Manage and track automated optimization campaigns

**Features:**
- Campaign creation and configuration
- Goal setting (target GEO score, recall %, etc.)
- Automated execution
- Progress tracking
- Performance reporting
- Campaign optimization

**Campaign Types:**
- Content creation campaigns
- Authority building campaigns
- Consistency improvement campaigns
- Full optimization campaigns

### 10.6 Automation Value Proposition

**For Consultants:**
- **Scale**: Execute GEO strategies for multiple clients simultaneously
- **Efficiency**: Automate repetitive tasks (content creation, publishing)
- **Consistency**: Ensure consistent execution across all clients
- **Speed**: Faster time-to-improvement for clients
- **Data-Driven**: Automated tracking and optimization

**For Clients:**
- **Faster Results**: Automated execution means faster GEO improvements
- **Consistent Quality**: Automated processes ensure consistent high-quality output
- **Comprehensive Coverage**: Automation can cover more platforms and touchpoints
- **Measurable Impact**: Clear tracking of automation effectiveness

**Key Differentiators:**
- Fully automated content creation optimized for AI training
- Multi-platform publishing automation
- Fully automated execution
- Performance-based campaign optimization
- Seamless integration with consultant workflows

---

## 10.7 Automation Workflows

### 10.7.1 Content Creation Workflow (Including Wiki Automation)

1. **Trigger**: Campaign created or opportunity detected
2. **Analysis**: System analyzes current GEO state and content gaps
3. **Generation**: Content generated from narratives using LLM
   - **Wiki pages are generated as primary content type**
   - **Wikipedia-compliant content generated automatically**
   - Blog posts, READMEs, documentation also generated
4. **Optimization**: Content optimized for AI training signals
   - **Wiki content specifically optimized for AI training**
   - Structured data, infoboxes, citations added
5. **Review**: Content automatically validated and optimized
   - **All wiki updates are fully automated**
   - Content automatically validated for quality and compliance
6. **Publishing**: Content published to appropriate platforms
   - **Wiki pages published to Wikipedia automatically**
   - **Company wikis updated automatically**
   - Other content published to respective platforms
7. **Tracking**: Performance tracked and measured
   - **Wiki page performance tracked**
   - **GEO score impact measured**
8. **Iteration**: Content strategy refined based on results
   - **Wiki pages automatically updated based on results**

### 10.7.2 Authority Building Workflow (Wiki-Focused)

1. **Analysis**: Identify authority gaps and opportunities
   - **Wiki page presence analysis**
   - **Wikipedia page gap detection**
2. **Strategy**: Select appropriate authority building tactics
   - **Wiki page creation** (one of the authority building techniques)
   - GitHub repository optimization
   - Documentation updates
   - Technical content creation
3. **Execution**: Automatically execute authority building activities
   - **Wiki pages created as part of authority building strategy**
   - **Wikipedia pages created/updated as part of authority optimization**
   - **Company wikis maintained as part of authority building**
   - GitHub repository optimization
   - Documentation updates
   - Technical content creation
   - Community engagement
4. **Tracking**: Monitor authority score improvements
   - **Wiki page contribution to authority tracked**
   - Overall authority score improvements
5. **Optimization**: Refine strategy based on results
   - **Wiki pages automatically optimized**
   - Strategy refined based on wiki performance

### 10.7.3 Consistency Management Workflow

### 10.7.4 Automated Wiki Management (Integrated Workflow)

**Wiki pages are automatically handled as part of all automation workflows:**

**During Campaign Execution:**
1. **Automatic Detection**: System automatically detects wiki page gaps
2. **Automatic Creation**: Wiki pages automatically created from narratives
3. **Automatic Optimization**: Wiki content automatically optimized for AI
4. **Automatic Publishing**: Wiki pages automatically published (fully automated)
5. **Automatic Tracking**: Wiki performance automatically tracked

**During Narrative Updates:**
1. **Automatic Detection**: System automatically detects narrative changes
2. **Automatic Sync**: Wiki pages automatically updated with new narrative
3. **Automatic Publishing**: Updates automatically published (fully automated)
4. **Automatic Verification**: Updates automatically verified

**During Consistency Management:**
1. **Automatic Detection**: Wiki inconsistencies automatically detected
2. **Automatic Fix**: Wiki pages automatically synchronized
3. **Automatic Publishing**: Fixes automatically published

**Key Automation Features:**
- Wiki pages are **automatically created** as part of content campaigns
- Wiki pages are **automatically updated** when narratives change
- Wikipedia pages are **automatically managed** (fully automated)
- Company wikis are **automatically maintained**
- Wiki performance is **automatically tracked** and optimized
- **No approval workflows** - everything is fully automated

1. **Detection**: Automatically detect messaging inconsistencies
2. **Analysis**: Identify sources of drift
3. **Synchronization**: Update all sources with consistent messaging
4. **Verification**: Verify consistency across all platforms
5. **Monitoring**: Continuously monitor for new inconsistencies
6. **Prevention**: Proactively prevent future drift

---

## 11. Out of Scope (V1)

- Self-serve optimization tools (client-facing)
- Client-visible automation controls
- Multi-LLM benchmarking UI
- Real-time monitoring dashboard (client-facing)
- API access for clients
- White-label solutions
- Mobile applications

---

## 12. Future Considerations

- Multi-LLM support (beyond OpenAI/Anthropic)
- Real-time monitoring capabilities
- API access for enterprise clients
- Advanced analytics and insights
- Integration with marketing tools (HubSpot, Salesforce)
- Advanced AI-powered content generation
- Predictive analytics for GEO improvements
- Automated competitor displacement strategies

