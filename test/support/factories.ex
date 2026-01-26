defmodule Thevis.Factory do
  @moduledoc """
  ExMachina factories for test data generation.
  """

  use ExMachina.Ecto, repo: Thevis.Repo

  alias Thevis.Accounts.Company
  alias Thevis.Accounts.Role
  alias Thevis.Accounts.User
  alias Thevis.Geo.EntitySnapshot
  alias Thevis.Scans.ScanResult
  alias Thevis.Scans.ScanRun

  def user_factory do
    %User{
      email: sequence(:email, &"user#{&1}@example.com"),
      name: sequence(:name, &"User #{&1}"),
      hashed_password: Bcrypt.hash_pwd_salt("password1234"),
      role: :client
    }
  end

  def consultant_user_factory do
    %User{
      email: sequence(:email, &"consultant#{&1}@example.com"),
      name: sequence(:name, &"Consultant #{&1}"),
      hashed_password: Bcrypt.hash_pwd_salt("password1234"),
      role: :consultant
    }
  end

  def company_factory do
    %Company{
      name: sequence(:name, &"Company #{&1}"),
      domain: sequence(:domain, &"company#{&1}.com"),
      industry: "Technology",
      description: "A test company",
      website_url: sequence(:url, &"https://company#{&1}.com"),
      company_type: :product_based
    }
  end

  def service_based_company_factory do
    %Company{
      name: sequence(:name, &"Service Company #{&1}"),
      domain: sequence(:domain, &"service#{&1}.com"),
      industry: "Services",
      description: "A service-based company",
      website_url: sequence(:url, &"https://service#{&1}.com"),
      company_type: :service_based
    }
  end

  def role_factory do
    %Role{
      user: build(:user),
      company: build(:company),
      role_type: :client
    }
  end

  def consultant_role_factory do
    %Role{
      user: build(:consultant_user),
      company: build(:company),
      role_type: :consultant
    }
  end

  def product_factory do
    %Thevis.Products.Product{
      company: build(:company),
      name: sequence(:name, &"Product #{&1}"),
      description: "A test product",
      category: "cosmetics",
      product_type: :cosmetic
    }
  end

  def product_in_launch_window_factory do
    today = Date.utc_today()
    start_date = Date.add(today, -7)
    end_date = Date.add(today, 7)

    %Thevis.Products.Product{
      company: build(:company),
      name: sequence(:name, &"Launch Product #{&1}"),
      description: "A product in launch window",
      category: "cosmetics",
      product_type: :cosmetic,
      launch_date: today,
      launch_window_start: start_date,
      launch_window_end: end_date
    }
  end

  def competitor_product_factory do
    %Thevis.Products.CompetitorProduct{
      product: build(:product),
      name: sequence(:name, &"Competitor Product #{&1}"),
      description: "A competitor product",
      category: "cosmetics",
      brand_name: "Competitor Brand"
    }
  end

  def project_factory do
    product = insert(:product)

    %Thevis.Projects.Project{
      name: sequence(:name, &"Project #{&1}"),
      description: "A test project",
      status: :active,
      scan_frequency: :weekly,
      project_type: :ongoing_monitoring,
      urgency_level: :standard,
      is_category_project: false,
      product: product
    }
  end

  def product_launch_project_factory do
    product = insert(:product)

    %Thevis.Projects.Project{
      name: sequence(:name, &"Launch Project #{&1}"),
      description: "A product launch project",
      status: :active,
      scan_frequency: :daily,
      project_type: :product_launch,
      urgency_level: :critical,
      is_category_project: false,
      product: product
    }
  end

  def product_project_factory do
    product = insert(:product)

    %Thevis.Projects.Project{
      name: sequence(:name, &"Product Project #{&1}"),
      description: "A project for a product",
      status: :active,
      scan_frequency: :weekly,
      project_type: :ongoing_monitoring,
      urgency_level: :standard,
      is_category_project: false,
      product: product
    }
  end

  def scan_run_factory do
    %ScanRun{
      project: build(:product_project),
      status: :pending,
      scan_type: :entity_probe
    }
  end

  def scan_result_factory do
    %ScanResult{
      scan_run: build(:scan_run),
      result_type: "entity_probe",
      data: %{},
      metrics: %{}
    }
  end

  def entity_snapshot_factory do
    product = insert(:product)

    %EntitySnapshot{
      scan_run: build(:scan_run),
      optimizable_type: :product,
      optimizable_id: product.id,
      ai_description: "A test product description from AI",
      confidence_score: 0.85,
      source_llm: "gpt-4o-mini",
      prompt_template: "product_probe"
    }
  end
end
