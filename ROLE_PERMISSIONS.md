# Role-Based Permissions & Access Control

Based on PRD.md, this document defines what clients can see/do vs what admins/consultants can see/do.

## Client Permissions (Role: `:client`)

### ✅ What Clients CAN Do

**View & Read:**
- View their own companies (via roles)
- View their own products (from their companies)
- View their own projects (from their products)
- View scan results for their own projects
- View GEO Score for their products
- View recall metrics for their products
- View authority scores (high-level only)
- View historical progress tracking
- Export PDF audit reports
- View AI-generated descriptions (read-only)

**Creation & Modification (Their Own Data):**
- ✅ Create companies (their own)
- ✅ Edit companies (their own)
- ✅ Delete companies (their own)
- ✅ Create products (for their companies)
- ✅ Edit products (their own)
- ✅ Delete products (their own)
- ✅ Create projects (for their products)
- ✅ Edit projects (their own)
- ✅ Delete projects (their own)
- ✅ Trigger scans (for their own projects)

**Routes:**
- `/dashboard` - Client dashboard (their own data)
- `/companies` - List their own companies
- `/companies/new` - Create their own company
- `/companies/:id` - View their own company details
- `/companies/:id/edit` - Edit their own company
- `/products` - List their own products
- `/products/new` - Create product for their companies
- `/products/:id` - View their own product details
- `/products/:id/edit` - Edit their own product
- `/projects` - List their own projects
- `/projects/new` - Create project for their products
- `/projects/:id` - View their own project details
- `/projects/:id/edit` - Edit their own project
- `/projects/:id/scans` - View scans for their own projects
- `/projects/:id/scans/:scan_run_id` - View scan details

### ❌ What Clients CANNOT Do

**Access Restrictions:**
- ❌ View other clients' data
- ❌ Edit other clients' companies/products/projects
- ❌ View system-wide statistics
- ❌ Access consultant-only features

**Information Access:**
- ❌ View tactical recommendations
- ❌ View playbooks
- ❌ View publishing strategies
- ❌ View narrative rules
- ❌ View opportunity detection details
- ❌ View execution plans
- ❌ Access internal consultant tools
- ❌ View other clients' data
- ❌ View system-wide statistics

## Admin/Consultant Permissions (Role: `:consultant`)

### ✅ What Admins CAN Do

**View & Read:**
- View ALL companies (across all clients)
- View ALL products (across all clients)
- View ALL projects (across all clients)
- View ALL scan results
- View system-wide statistics
- View all internal tools and features

**Creation & Modification:**
- ✅ Create companies (for clients)
- ✅ Edit companies
- ✅ Delete companies
- ✅ Create products
- ✅ Edit products
- ✅ Delete products
- ✅ Create projects
- ✅ Edit projects
- ✅ Delete projects
- ✅ Trigger scans
- ✅ Manage all client data

**Consultant-Only Features:**
- ✅ Access opportunity detection engine
- ✅ Access playbook engine
- ✅ Access narrative builder
- ✅ Access execution planner
- ✅ Access consultant task board
- ✅ Access automated optimization engine
- ✅ Manage wiki pages
- ✅ View tactical recommendations
- ✅ View publishing strategies
- ✅ View narrative rules
- ✅ View execution plans

**Routes:**
- `/admin/dashboard` - Admin dashboard (all data)
- `/admin/companies` - List all companies
- `/admin/companies/new` - Create company
- `/admin/companies/:id` - View any company
- `/admin/companies/:id/edit` - Edit any company
- `/admin/products` - List all products
- `/admin/products/new` - Create product
- `/admin/products/:id` - View any product
- `/admin/products/:id/edit` - Edit any product
- `/admin/projects` - List all projects
- `/admin/projects/new` - Create project
- `/admin/projects/:id` - View any project
- `/admin/projects/:id/edit` - Edit any project
- `/admin/projects/:id/scans` - View scans for any project
- `/admin/projects/:id/scans/:scan_run_id` - View scan details

## Implementation Notes

1. **Route Protection:**
   - Client routes (`/companies`, `/products`, `/projects`) → Filter by user's companies
   - Admin routes (`/admin/*`) → Show all data, require `:consultant` role

2. **UI Visibility:**
   - Hide "Create" buttons from client views
   - Hide "Edit" buttons from client views
   - Hide consultant-only features from client navigation
   - Show different dashboard content based on role

3. **Data Filtering:**
   - Clients: Filter by `user.roles` → `company_ids` → products → projects
   - Admins: No filtering, show all data

4. **Feature Access:**
   - Consultant-only features should only be accessible via `/admin/*` routes
   - Client routes should not expose consultant tools

