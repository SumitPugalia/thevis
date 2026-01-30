defmodule Thevis.Jobs.ContentGeneration do
  @moduledoc """
  Background job for generating content items.
  """

  use Oban.Worker, queue: :reports, max_attempts: 3

  alias Thevis.Automation
  alias Thevis.Automation.ContentHelpers
  alias Thevis.Geo.Automation.ContentCreator
  alias Thevis.Projects

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "project_id" => project_id,
          "content_type" => content_type_str,
          "campaign_id" => campaign_id
        }
      }) do
    project = Projects.get_project(project_id)
    _campaign = Automation.get_campaign!(campaign_id)
    content_type = String.to_existing_atom(content_type_str)

    case project do
      nil ->
        {:error, :project_not_found}

      proj ->
        create_content_item_for_project(proj, project_id, content_type, campaign_id)
    end
  end

  defp create_content_item_for_project(project, project_id, content_type, campaign_id) do
    case ContentCreator.generate_content(project, content_type) do
      {:ok, content} ->
        platform = ContentHelpers.get_platform_for_content_type(content_type)

        attrs = %{
          campaign_id: campaign_id,
          project_id: project_id,
          content_type: content_type,
          title: ContentHelpers.generate_title(project, content_type),
          content: content,
          platform: platform,
          status: :draft
        }

        case Automation.create_content_item(attrs) do
          {:ok, content_item} -> {:ok, content_item.id}
          {:error, changeset} -> {:error, changeset}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
