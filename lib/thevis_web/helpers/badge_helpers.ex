defmodule ThevisWeb.Helpers.BadgeHelpers do
  @moduledoc """
  Centralized Tailwind CSS class strings for status/type badges used across LiveViews.
  Returns "bg-{color}-100 text-{color}-800" style classes for pill badges.
  """

  @default "bg-gray-100 text-gray-800"

  # Scan run status (pending, running, completed, failed)
  def scan_run_status_badge(:pending), do: "bg-gray-100 text-gray-800"
  def scan_run_status_badge(:running), do: "bg-blue-100 text-blue-800"
  def scan_run_status_badge(:completed), do: "bg-green-100 text-green-800"
  def scan_run_status_badge(:failed), do: "bg-red-100 text-red-800"
  def scan_run_status_badge(_), do: @default

  # Campaign status (draft, active, paused, completed, failed)
  def campaign_status_badge(:draft), do: "bg-gray-100 text-gray-800"
  def campaign_status_badge(:active), do: "bg-green-100 text-green-800"
  def campaign_status_badge(:paused), do: "bg-yellow-100 text-yellow-800"
  def campaign_status_badge(:completed), do: "bg-blue-100 text-blue-800"
  def campaign_status_badge(:failed), do: "bg-red-100 text-red-800"
  def campaign_status_badge(_), do: @default

  # Task status (pending, in_progress, completed, blocked)
  def task_status_badge(:pending), do: "bg-gray-100 text-gray-800"
  def task_status_badge(:in_progress), do: "bg-blue-100 text-blue-800"
  def task_status_badge(:completed), do: "bg-green-100 text-green-800"
  def task_status_badge(:blocked), do: "bg-red-100 text-red-800"
  def task_status_badge(_), do: @default

  # Wiki page status (draft, published, archived, failed)
  def wiki_page_status_badge(:draft), do: "bg-gray-100 text-gray-800"
  def wiki_page_status_badge(:published), do: "bg-green-100 text-green-800"
  def wiki_page_status_badge(:archived), do: "bg-yellow-100 text-yellow-800"
  def wiki_page_status_badge(:failed), do: "bg-red-100 text-red-800"
  def wiki_page_status_badge(_), do: @default

  # Project status (active, paused, archived)
  def project_status_badge(:active), do: "bg-green-100 text-green-800"
  def project_status_badge(:paused), do: "bg-yellow-100 text-yellow-800"
  def project_status_badge(:archived), do: "bg-gray-100 text-gray-800"
  def project_status_badge(_), do: @default

  # Task priority (low, medium, high, critical)
  def priority_badge(:low), do: "bg-gray-100 text-gray-800"
  def priority_badge(:medium), do: "bg-yellow-100 text-yellow-800"
  def priority_badge(:high), do: "bg-orange-100 text-orange-800"
  def priority_badge(:critical), do: "bg-red-100 text-red-800"
  def priority_badge(_), do: @default

  # Scan type (entity_probe, recall, authority, consistency, full)
  def scan_type_badge(:entity_probe), do: "bg-purple-100 text-purple-800"
  def scan_type_badge(:recall), do: "bg-indigo-100 text-indigo-800"
  def scan_type_badge(:authority), do: "bg-yellow-100 text-yellow-800"
  def scan_type_badge(:consistency), do: "bg-pink-100 text-pink-800"
  def scan_type_badge(:full), do: "bg-blue-100 text-blue-800"
  def scan_type_badge(_), do: @default

  # Campaign type (content, authority, consistency, full, product_launch)
  def campaign_type_badge(:content), do: "bg-purple-100 text-purple-800"
  def campaign_type_badge(:authority), do: "bg-indigo-100 text-indigo-800"
  def campaign_type_badge(:consistency), do: "bg-pink-100 text-pink-800"
  def campaign_type_badge(:full), do: "bg-blue-100 text-blue-800"
  def campaign_type_badge(:product_launch), do: "bg-orange-100 text-orange-800"
  def campaign_type_badge(_), do: @default

  # Wiki page type (product, company, service)
  def wiki_page_type_badge(:product), do: "bg-blue-100 text-blue-800"
  def wiki_page_type_badge(:company), do: "bg-purple-100 text-purple-800"
  def wiki_page_type_badge(:service), do: "bg-indigo-100 text-indigo-800"
  def wiki_page_type_badge(_), do: @default

  # Platform type (string keys: github, medium, blog, wordpress, contentful)
  def platform_type_badge("github"), do: "bg-purple-100 text-purple-800"
  def platform_type_badge("medium"), do: "bg-green-100 text-green-800"
  def platform_type_badge("blog"), do: "bg-blue-100 text-blue-800"
  def platform_type_badge("wordpress"), do: "bg-blue-100 text-blue-800"
  def platform_type_badge("contentful"), do: "bg-indigo-100 text-indigo-800"
  def platform_type_badge(_), do: @default

  # Product type (cosmetic, edible, sweet, d2c, fashion, wellness, other)
  def product_type_badge(:cosmetic), do: "bg-pink-100 text-pink-800"
  def product_type_badge(:edible), do: "bg-green-100 text-green-800"
  def product_type_badge(:sweet), do: "bg-yellow-100 text-yellow-800"
  def product_type_badge(:d2c), do: "bg-blue-100 text-blue-800"
  def product_type_badge(:fashion), do: "bg-purple-100 text-purple-800"
  def product_type_badge(:wellness), do: "bg-indigo-100 text-indigo-800"
  def product_type_badge(_), do: @default

  # Company type (product_based, service_based)
  def company_type_badge(:product_based), do: "bg-blue-100 text-blue-800"
  def company_type_badge(:service_based), do: "bg-purple-100 text-purple-800"
  def company_type_badge(_), do: @default

  # Project type (product_launch, ongoing_monitoring, audit_only)
  def project_type_badge(:product_launch), do: "bg-red-100 text-red-800"
  def project_type_badge(:ongoing_monitoring), do: "bg-green-100 text-green-800"
  def project_type_badge(:audit_only), do: "bg-gray-100 text-gray-800"
  def project_type_badge(_), do: @default
end
