defmodule Thevis.Jobs.WikiSync do
  @moduledoc """
  Background job for syncing wiki pages with narrative changes.
  """

  use Oban.Worker, queue: :reports, max_attempts: 2

  alias Thevis.Geo.Automation.WikiManager
  alias Thevis.Projects

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"project_id" => project_id}}) do
    project = Projects.get_project(project_id)

    if project do
      case WikiManager.sync_wiki_pages(project) do
        {:ok, _results} -> :ok
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, :project_not_found}
    end
  end
end
