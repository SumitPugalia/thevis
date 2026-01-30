# Script for populating the database with mock data for visualization
#
# Run it as:
#
#     mix run priv/repo/seeds.exs
#

import Ecto.Query

alias Thevis.Repo
alias Thevis.Accounts
alias Thevis.Products
alias Thevis.Projects
alias Thevis.Scans
alias Thevis.Geo
alias Thevis.Strategy
alias Thevis.Wikis
alias Thevis.Automation
alias Thevis.Integrations

# Create consultant user
consultant =
  case Accounts.get_user_by_email("consultant@thevis.ai") do
    nil ->
      {:ok, user} =
        Accounts.create_user(%{
          email: "consultant@thevis.ai",
          name: "Admin Consultant",
          password: "password1234",
          role: :consultant
        })

      user

    user ->
      user
  end

# Create client users
client1 =
  case Accounts.get_user_by_email("client1@example.com") do
    nil ->
      {:ok, user} =
        Accounts.create_user(%{
          email: "client1@example.com",
          name: "John Smith",
          password: "password1234",
          role: :client
        })

      user

    user ->
      user
  end

client2 =
  case Accounts.get_user_by_email("client2@example.com") do
    nil ->
      {:ok, user} =
        Accounts.create_user(%{
          email: "client2@example.com",
          name: "Sarah Johnson",
          password: "password1234",
          role: :client
        })

      user

    user ->
      user
  end

# Create companies
company1 =
  case Repo.get_by(Accounts.Company, domain: "glowbeauty.com") do
    nil ->
      {:ok, company} =
        Accounts.create_company(%{
          name: "Glow Beauty",
          domain: "glowbeauty.com",
          industry: "Cosmetics",
          website_url: "https://glowbeauty.com",
          description: "Premium skincare and cosmetics brand",
          company_type: :product_based,
          competitors: [
            %{name: "L'Oreal", domain: "loreal.com"},
            %{name: "Estee Lauder", domain: "esteelauder.com"},
            %{name: "MAC Cosmetics", domain: "maccosmetics.com"}
          ]
        })

      # Assign owner role
      Accounts.assign_role(client1, company, :owner)

      company

    company ->
      company
  end

company2 =
  case Repo.get_by(Accounts.Company, domain: "techstart.io") do
    nil ->
      {:ok, company} =
        Accounts.create_company(%{
          name: "TechStart Solutions",
          domain: "techstart.io",
          industry: "Technology",
          website_url: "https://techstart.io",
          description: "Enterprise software solutions",
          company_type: :product_based,
          competitors: [
            %{name: "Salesforce", domain: "salesforce.com"},
            %{name: "Microsoft", domain: "microsoft.com"},
            %{name: "Oracle", domain: "oracle.com"}
          ]
        })

      # Assign owner role
      Accounts.assign_role(client2, company, :owner)

      company

    company ->
      company
  end

# Create products for company1
product1 =
  case Repo.get_by(Products.Product, name: "Glow Serum Pro") do
    nil ->
      {:ok, product} =
        Products.create_product(company1, %{
          name: "Glow Serum Pro",
          description: "Advanced anti-aging serum with vitamin C and retinol",
          category: "Skincare",
          product_type: :cosmetic,
          launch_date: ~D[2024-01-15]
        })

      product

    product ->
      product
  end

product2 =
  case Repo.get_by(Products.Product, name: "Hydrating Face Mask") do
    nil ->
      {:ok, product} =
        Products.create_product(company1, %{
          name: "Hydrating Face Mask",
          description: "Deep hydrating mask with hyaluronic acid",
          category: "Skincare",
          product_type: :cosmetic,
          launch_date: ~D[2024-02-01]
        })

      product

    product ->
      product
  end

# Create products for company2
product3 =
  case Repo.get_by(Products.Product, name: "CloudSync Pro") do
    nil ->
      {:ok, product} =
        Products.create_product(company2, %{
          name: "CloudSync Pro",
          description: "Enterprise cloud synchronization platform",
          category: "Software",
          product_type: :other,
          launch_date: ~D[2024-03-01]
        })

      product

    product ->
      product
  end

# Create projects
project1 =
  case Repo.get_by(Projects.Project, name: "Glow Serum Launch Campaign") do
    nil ->
      {:ok, project} =
        Projects.create_project_for_product(product1, %{
          name: "Glow Serum Launch Campaign",
          description: "Product launch optimization campaign",
          status: :active,
          scan_frequency: :weekly,
          project_type: :product_launch,
          urgency_level: :high
        })

      project

    project ->
      project
  end

project2 =
  case Repo.get_by(Projects.Project, name: "Hydrating Mask Ongoing Optimization") do
    nil ->
      {:ok, project} =
        Projects.create_project_for_product(product2, %{
          name: "Hydrating Mask Ongoing Optimization",
          description: "Ongoing monitoring and optimization",
          status: :active,
          scan_frequency: :monthly,
          project_type: :ongoing_monitoring,
          urgency_level: :standard
        })

      project

    project ->
      project
  end

project3 =
  case Repo.get_by(Projects.Project, name: "CloudSync Pro Launch") do
    nil ->
      {:ok, project} =
        Projects.create_project_for_product(product3, %{
          name: "CloudSync Pro Launch",
          description: "Enterprise software launch campaign",
          status: :active,
          scan_frequency: :daily,
          project_type: :product_launch,
          urgency_level: :critical
        })

      project

    project ->
      project
  end

# Create scan runs with historical data (last 30 days)
now = DateTime.utc_now()

# Generate scan runs for project1 (weekly scans, last 4 weeks)
scan_runs_project1 =
  Enum.map(0..3, fn week_offset ->
    scan_date = DateTime.add(now, -week_offset * 7 * 24 * 3600, :second)

    case Repo.one(
           from(sr in Scans.ScanRun,
             where: sr.project_id == ^project1.id,
             where: fragment("DATE(?) = DATE(?)", sr.inserted_at, ^scan_date),
             limit: 1
           )
         ) do
      nil ->
        {:ok, scan_run} =
          Scans.create_scan_run(project1, %{
            scan_type: :entity_probe,
            status: :completed,
            started_at: DateTime.add(scan_date, -3600, :second),
            completed_at: scan_date
          })

        # Create entity snapshot
        {:ok, _snapshot} =
          Geo.create_entity_snapshot(scan_run, %{
            optimizable_type: :product,
            optimizable_id: product1.id,
            ai_description:
              "Premium anti-aging serum with vitamin C and retinol for glowing skin",
            confidence_score: 0.75 + :rand.uniform() * 0.2,
            source_llm: "gpt-4",
            prompt_template: "product_probe"
          })

        # Create recall results
        Enum.each(1..6, fn i ->
          Geo.create_recall_result(scan_run, %{
            product_id: product1.id,
            prompt_category:
              [
                "product_search",
                "category_search",
                "use_case",
                "comparison",
                "recommendation",
                "general"
              ]
              |> Enum.at(i - 1),
            prompt_text: "What are the best #{product1.category} products?",
            mentioned: i <= 4,
            mention_rank: if(i <= 4, do: i, else: nil),
            response_text: "Some great #{product1.category} products include #{product1.name}...",
            raw_response: %{
              "content" => "Some great #{product1.category} products include #{product1.name}..."
            }
          })
        end)

        scan_run

      existing ->
        existing
    end
  end)

# Generate scan runs for project2 (monthly scans, last 3 months)
scan_runs_project2 =
  Enum.map(0..2, fn month_offset ->
    scan_date = DateTime.add(now, -month_offset * 30 * 24 * 3600, :second)

    case Repo.one(
           from(sr in Scans.ScanRun,
             where: sr.project_id == ^project2.id,
             where: fragment("DATE(?) = DATE(?)", sr.inserted_at, ^scan_date),
             limit: 1
           )
         ) do
      nil ->
        {:ok, scan_run} =
          Scans.create_scan_run(project2, %{
            scan_type: :entity_probe,
            status: :completed,
            started_at: DateTime.add(scan_date, -3600, :second),
            completed_at: scan_date
          })

        # Create entity snapshot
        {:ok, _snapshot} =
          Geo.create_entity_snapshot(scan_run, %{
            optimizable_type: :product,
            optimizable_id: product2.id,
            ai_description: "Deep hydrating face mask with hyaluronic acid for intense moisture",
            confidence_score: 0.70 + :rand.uniform() * 0.25,
            source_llm: "gpt-4",
            prompt_template: "product_probe"
          })

        scan_run

      existing ->
        existing
    end
  end)

# Generate scan runs for project3 (daily scans, last 7 days)
scan_runs_project3 =
  Enum.map(0..6, fn day_offset ->
    scan_date = DateTime.add(now, -day_offset * 24 * 3600, :second)

    case Repo.one(
           from(sr in Scans.ScanRun,
             where: sr.project_id == ^project3.id,
             where: fragment("DATE(?) = DATE(?)", sr.inserted_at, ^scan_date),
             limit: 1
           )
         ) do
      nil ->
        {:ok, scan_run} =
          Scans.create_scan_run(project3, %{
            scan_type: :entity_probe,
            status: :completed,
            started_at: DateTime.add(scan_date, -3600, :second),
            completed_at: scan_date
          })

        # Create entity snapshot
        {:ok, _snapshot} =
          Geo.create_entity_snapshot(scan_run, %{
            optimizable_type: :product,
            optimizable_id: product3.id,
            ai_description:
              "Enterprise cloud synchronization platform for seamless data management",
            confidence_score: 0.80 + :rand.uniform() * 0.15,
            source_llm: "gpt-4",
            prompt_template: "product_probe"
          })

        # Create recall results
        Enum.each(1..6, fn i ->
          Geo.create_recall_result(scan_run, %{
            product_id: product3.id,
            prompt_category:
              [
                "product_search",
                "category_search",
                "use_case",
                "comparison",
                "recommendation",
                "general"
              ]
              |> Enum.at(i - 1),
            prompt_text: "What are the best cloud sync solutions?",
            mentioned: i <= 5,
            mention_rank: if(i <= 5, do: i, else: nil),
            response_text: "Top cloud sync solutions include #{product3.name}...",
            raw_response: %{
              "content" => "Top cloud sync solutions include #{product3.name}..."
            }
          })
        end)

        scan_run

      existing ->
        existing
    end
  end)

# --- Strategy: Playbooks, Narratives, Tasks ---
playbook1 =
  case Repo.one(
         from(p in Thevis.Strategy.Playbook,
           where: p.name == "Product Launch Visibility",
           where: p.project_id == ^project1.id,
           limit: 1
         )
       ) do
    nil ->
      {:ok, pb} =
        Strategy.create_playbook(%{
          name: "Product Launch Visibility",
          description: "Boost visibility for new product launches via content and authority",
          category: "product_launch",
          project_id: project1.id,
          is_template: false,
          steps: %{
            "1" => "Run entity probe scan",
            "2" => "Generate wiki content",
            "3" => "Publish to configured platforms"
          }
        })

      pb

    pb ->
      pb
  end

playbook2 =
  case Repo.one(
         from(p in Thevis.Strategy.Playbook,
           where: p.name == "Ongoing Consistency Check",
           where: p.project_id == ^project2.id,
           limit: 1
         )
       ) do
    nil ->
      {:ok, pb} =
        Strategy.create_playbook(%{
          name: "Ongoing Consistency Check",
          description: "Monthly consistency and recall monitoring",
          category: "ongoing",
          project_id: project2.id,
          is_template: false,
          steps: %{"1" => "Run recall test", "2" => "Review drift scores"}
        })

      pb

    pb ->
      pb
  end

playbook3 =
  case Repo.one(
         from(p in Thevis.Strategy.Playbook,
           where: p.name == "Enterprise Launch Playbook",
           where: p.project_id == ^project3.id,
           limit: 1
         )
       ) do
    nil ->
      {:ok, pb} =
        Strategy.create_playbook(%{
          name: "Enterprise Launch Playbook",
          description: "Full campaign for enterprise software launch",
          category: "product_launch",
          project_id: project3.id,
          is_template: false,
          steps: %{
            "1" => "Entity probe",
            "2" => "Content generation",
            "3" => "Wiki sync",
            "4" => "Authority tracking"
          }
        })

      pb

    pb ->
      pb
  end

# Narratives
for {project, content} <- [
      {project1,
       "Glow Beauty is a premium skincare brand focused on science-backed anti-aging and radiance. Our hero product Glow Serum Pro combines vitamin C and retinol for visible results."},
      {project2,
       "Hydrating Face Mask is our best-selling mask with hyaluronic acid for intense moisture. Ideal for all skin types, especially dry and dehydrated skin."},
      {project3,
       "CloudSync Pro is an enterprise-grade cloud synchronization platform. We help teams keep data in sync across devices with security and compliance built in."}
    ] do
  case Repo.one(
         from(n in Thevis.Strategy.Narrative, where: n.project_id == ^project.id, limit: 1)
       ) do
    nil ->
      Strategy.create_narrative(%{
        project_id: project.id,
        content: content,
        version: 1,
        is_active: true,
        rules: %{}
      })

    _ ->
      :ok
  end
end

# Tasks (some assigned to consultant)
task_attrs_list = [
  {project1, "Review last scan results", "Check entity probe and recall metrics", :high, :pending,
   consultant.id},
  {project1, "Update product narrative", "Refresh narrative for Q1 campaign", :medium,
   :in_progress, consultant.id},
  {project1, "Schedule wiki publish", "Publish Glow Serum page to Confluence", :low, :pending,
   nil},
  {project2, "Monthly recall report", "Generate and share recall report", :high, :completed,
   consultant.id},
  {project3, "Configure GitHub integration", "Add repo for README updates", :critical, :pending,
   consultant.id},
  {project3, "Draft blog post", "First thought-leadership post for CloudSync", :medium, :pending,
   nil}
]

for {project, title, desc, priority, status, assigned_id} <- task_attrs_list do
  case Repo.one(
         from(t in Thevis.Strategy.Task,
           where: t.project_id == ^project.id and t.title == ^title,
           limit: 1
         )
       ) do
    nil ->
      Strategy.create_task(%{
        project_id: project.id,
        title: title,
        description: desc,
        priority: priority,
        status: status,
        assigned_to_id: assigned_id,
        due_date: Date.add(Date.utc_today(), 7)
      })

    _ ->
      :ok
  end
end

# --- Wikis: Platforms, Pages, Content ---
wiki_platforms =
  ["Confluence (Mock)", "Notion (Mock)", "Wikipedia"]
  |> Enum.map(fn name ->
    type =
      cond do
        name =~ "Confluence" -> "confluence"
        name =~ "Notion" -> "notion"
        true -> "wikipedia"
      end

    case Wikis.get_wiki_platform_by_name(name) do
      nil ->
        {:ok, p} =
          Wikis.create_wiki_platform(%{
            name: name,
            platform_type: type,
            api_endpoint: if(type == "wikipedia", do: nil, else: "https://example.com/api"),
            is_active: true,
            config: %{}
          })

        p

      p ->
        p
    end
  end)

[platform_confluence, platform_notion, _platform_wiki] = wiki_platforms

# Wiki pages for projects
wiki_page_attrs = [
  {project1, platform_confluence, "Glow Serum Pro - Product Overview", :product, :published},
  {project1, platform_notion, "Glow Beauty Skincare Line", :company, :draft},
  {project2, platform_confluence, "Hydrating Face Mask", :product, :published},
  {project3, platform_confluence, "CloudSync Pro Documentation", :product, :published}
]

created_wiki_pages =
  for {project, platform, title, page_type, status} <- wiki_page_attrs do
    case Wikis.get_wiki_page_by_title(project.id, title) do
      nil ->
        {:ok, wp} =
          Wikis.create_wiki_page(%{
            project_id: project.id,
            platform_id: platform.id,
            title: title,
            status: status,
            page_type: page_type,
            url: "https://example.com/wiki/#{String.replace(title, " ", "-")}",
            external_id:
              "ext-#{Base.encode16(binary_part(project.id, 0, 8), case: :lower)}-#{page_type}"
          })

        wp

      wp ->
        wp
    end
  end

# Wiki content for first two pages
for {wp, body} <-
      Enum.zip(Enum.take(created_wiki_pages, 2), [
        "Glow Serum Pro is our flagship anti-aging serum with vitamin C and retinol. Use daily for best results.",
        "Glow Beauty offers a full skincare line focused on radiance and hydration."
      ]) do
  case Repo.one(from(wc in Thevis.Wikis.WikiContent, where: wc.wiki_page_id == ^wp.id, limit: 1)) do
    nil ->
      Wikis.create_wiki_content(%{
        wiki_page_id: wp.id,
        content: body,
        version: 1,
        is_published: wp.status == :published,
        published_at: if(wp.status == :published, do: DateTime.utc_now(), else: nil)
      })

    _ ->
      :ok
  end
end

# --- Automation: Campaigns, Content Items ---
campaign_attrs = [
  {project1, playbook1, "Glow Serum Q1 Launch", :product_launch, :active},
  {project2, playbook2, "Hydrating Mask Q1 Consistency", :consistency, :completed},
  {project3, playbook3, "CloudSync Pro Launch Campaign", :full, :active}
]

created_campaigns =
  for {project, playbook, name, campaign_type, status} <- campaign_attrs do
    case Repo.one(
           from(c in Thevis.Automation.Campaign,
             where: c.project_id == ^project.id and c.name == ^name,
             limit: 1
           )
         ) do
      nil ->
        {:ok, camp} =
          Automation.create_campaign(%{
            project_id: project.id,
            playbook_id: playbook.id,
            name: name,
            description: "Automation campaign for #{name}",
            status: status,
            campaign_type: campaign_type,
            intensity: :high,
            started_at:
              if(status in [:active, :completed],
                do: DateTime.add(DateTime.utc_now(), -86400 * 3, :second),
                else: nil
              ),
            completed_at: if(status == :completed, do: DateTime.utc_now(), else: nil)
          })

        camp

      c ->
        c
    end
  end

[campaign1, campaign2, campaign3] = created_campaigns

content_item_attrs = [
  {campaign1, project1, "Glow Serum Pro Launch Blog", :blog_post, :blog, :published},
  {campaign1, project1, "Glow Serum README", :github_readme, :github, :draft},
  {campaign2, project2, "Hydrating Mask Wiki Update", :wiki_page, :company_wiki, :published},
  {campaign3, project3, "CloudSync Pro Intro Article", :article, :medium, :scheduled},
  {campaign3, project3, "CloudSync Docs Home", :documentation, :docs, :draft}
]

for {campaign, project, title, content_type, platform, status} <- content_item_attrs do
  case Repo.one(
         from(ci in Thevis.Automation.ContentItem,
           where: ci.campaign_id == ^campaign.id and ci.title == ^title,
           limit: 1
         )
       ) do
    nil ->
      Automation.create_content_item(%{
        campaign_id: campaign.id,
        project_id: project.id,
        title: title,
        content: "This is mock content for #{title}. Replace with real generated content.",
        content_type: content_type,
        platform: platform,
        status: status,
        ai_optimization_score: 0.72 + :rand.uniform() * 0.2,
        published_at: if(status == :published, do: DateTime.utc_now(), else: nil),
        scheduled_at:
          if(status == :scheduled,
            do: DateTime.add(DateTime.utc_now(), 86400, :second),
            else: nil
          )
      })

    _ ->
      :ok
  end
end

# --- Integrations: Platform Settings ---
for {project, platform_type} <- [
      {project1, "github"},
      {project1, "contentful"},
      {project2, "github"},
      {project3, "github"},
      {project3, "medium"}
    ] do
  case Integrations.get_platform_setting_by_type(project.id, platform_type) do
    nil ->
      Integrations.create_platform_setting(%{
        project_id: project.id,
        platform_type: platform_type,
        settings: %{"enabled" => true, "sync_frequency" => "weekly"},
        is_active: true
      })

    _ ->
      :ok
  end
end

IO.puts("""
✅ Seed data created successfully!

Users:
  - Consultant: consultant@thevis.ai / password1234
  - Client 1: client1@example.com / password1234
  - Client 2: client2@example.com / password1234

Companies:
  - Glow Beauty (glowbeauty.com) - Owned by Client 1
  - TechStart Solutions (techstart.io) - Owned by Client 2

Products:
  - Glow Serum Pro (Glow Beauty)
  - Hydrating Face Mask (Glow Beauty)
  - CloudSync Pro (TechStart Solutions)

Projects:
  - Glow Serum Launch Campaign (4 weekly scans)
  - Hydrating Mask Ongoing Optimization (3 monthly scans)
  - CloudSync Pro Launch (7 daily scans)

Total scan runs created: #{length(scan_runs_project1) + length(scan_runs_project2) + length(scan_runs_project3)}

Strategy: Playbooks (3), Narratives (3), Tasks (6, some assigned to consultant)
Wikis: Platforms (3), Wiki pages (4), Wiki contents (2)
Automation: Campaigns (3), Content items (5)
Integrations: Platform settings (5) for GitHub, Contentful, Medium
""")
