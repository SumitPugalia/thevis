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
          competitors: ["L'Oreal", "Estee Lauder", "MAC Cosmetics"]
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
          competitors: ["Salesforce", "Microsoft", "Oracle"]
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
        Products.create_product(%{
          name: "Glow Serum Pro",
          description: "Advanced anti-aging serum with vitamin C and retinol",
          category: "Skincare",
          product_type: :cosmetic,
          company_id: company1.id,
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
        Products.create_product(%{
          name: "Hydrating Face Mask",
          description: "Deep hydrating mask with hyaluronic acid",
          category: "Skincare",
          product_type: :cosmetic,
          company_id: company1.id,
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
        Products.create_product(%{
          name: "CloudSync Pro",
          description: "Enterprise cloud synchronization platform",
          category: "Software",
          product_type: :saas,
          company_id: company2.id,
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
        recall_percentage = 60.0 + :rand.uniform() * 20.0

        Enum.each(1..6, fn i ->
          Geo.create_recall_result(%{
            scan_run_id: scan_run.id,
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
          Geo.create_recall_result(%{
            scan_run_id: scan_run.id,
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
""")
