defmodule Thevis.Jobs.WikiCreation do
  @moduledoc """
  Background job for creating wiki pages from narratives.
  """

  use Oban.Worker, queue: :reports, max_attempts: 3

  alias Thevis.Geo.Automation.WikiManager
  alias Thevis.Projects

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "project_id" => project_id,
          "platform_name" => platform_name,
          "page_type" => page_type_str
        }
      }) do
    project = Projects.get_project(project_id)

    if project do
      page_type = String.to_existing_atom(page_type_str)

      case WikiManager.create_wiki_page(project, platform_name, page_type) do
        {:ok, _wiki_page, _wiki_content} -> :ok
        {:error, :narrative_not_found} -> {:error, :narrative_not_found}
        {:error, :platform_not_found} -> {:error, :platform_not_found}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, :project_not_found}
    end
  end
end
