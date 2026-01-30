defmodule Thevis.Jobs.WikiPublishing do
  @moduledoc """
  Background job for publishing wiki pages to platforms.
  """

  use Oban.Worker, queue: :reports, max_attempts: 3

  alias Thevis.Geo.Automation.WikiManager
  alias Thevis.Wikis

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"wiki_page_id" => wiki_page_id}}) do
    wiki_page = Wikis.get_wiki_page!(wiki_page_id)

    case WikiManager.publish_wiki_page(wiki_page) do
      {:ok, _updated_page} -> :ok
      {:error, :no_content} -> {:error, :no_content}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
