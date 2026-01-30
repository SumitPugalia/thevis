defmodule Thevis.Geo.AuthorityGraph do
  @moduledoc """
  Authority Graph module for building and analyzing authority relationships.
  """

  alias Thevis.Accounts.Company
  alias Thevis.Geo.AuthorityScore
  alias Thevis.Products.Product
  alias Thevis.Repo

  @doc """
  Builds an authority graph for a given optimizable entity.
  """
  def build_authority_graph(optimizable) do
    sources = [
      :github,
      :medium,
      :news,
      :website
    ]

    results =
      Enum.map(sources, fn source_type ->
        case Thevis.Geo.Crawler.crawl_source(source_type, optimizable) do
          {:ok, crawl_data} ->
            score = calculate_authority_score(crawl_data)
            %{source_type: source_type, score: score, data: crawl_data}

          {:error, _reason} ->
            %{source_type: source_type, score: 0.0, data: nil}
        end
      end)

    {:ok, results}
  end

  @doc """
  Calculates authority score for a source.
  """
  def calculate_authority_score(crawl_data) do
    # Simple scoring algorithm - can be enhanced
    base_score = 0.5

    score =
      cond do
        crawl_data[:content] && String.length(crawl_data[:content]) > 100 -> base_score + 0.2
        crawl_data[:title] && String.length(crawl_data[:title]) > 10 -> base_score + 0.1
        true -> base_score
      end

    # Normalize to 0-1 range
    min(score, 1.0)
  end

  @doc """
  Calculates overall authority score from multiple sources.
  """
  def calculate_overall_authority_score(sources) when is_list(sources) do
    if sources == [] do
      0.0
    else
      scores = Enum.map(sources, & &1[:score])
      Enum.sum(scores) / length(scores)
    end
  end

  @doc """
  Identifies authority gaps by comparing with competitors.
  """
  def identify_gaps(optimizable, competitors) do
    {:ok, optimizable_sources} = build_authority_graph(optimizable)

    competitor_sources =
      Enum.map(competitors, fn competitor ->
        {:ok, sources} = build_authority_graph(competitor)
        sources
      end)

    gaps = find_missing_sources(optimizable_sources, competitor_sources)

    {:ok, gaps}
  end

  defp find_missing_sources(optimizable_sources, competitor_sources) do
    optimizable_source_types = Enum.map(optimizable_sources, & &1[:source_type])

    all_competitor_source_types =
      competitor_sources
      |> List.flatten()
      |> Enum.map(& &1[:source_type])
      |> Enum.uniq()

    missing = all_competitor_source_types -- optimizable_source_types

    Enum.map(missing, fn source_type ->
      %{
        source_type: source_type,
        recommendation: "Consider adding #{source_type} presence"
      }
    end)
  end

  @doc """
  Stores authority scores in the database.
  """
  def store_authority_scores(optimizable, sources) do
    optimizable_type = get_optimizable_type(optimizable)
    optimizable_id = optimizable.id

    Enum.each(sources, fn source ->
      attrs = %{
        optimizable_type: optimizable_type,
        optimizable_id: optimizable_id,
        authority_score: source[:score],
        source_type: to_string(source[:source_type]),
        source_url: source[:data][:source_url],
        source_title: source[:data][:title],
        source_content: source[:data][:content],
        crawled_at: DateTime.utc_now(),
        metadata: source[:data][:metadata] || %{}
      }

      %AuthorityScore{}
      |> AuthorityScore.changeset(attrs)
      |> Repo.insert()
    end)
  end

  defp get_optimizable_type(%Product{}), do: :product
  defp get_optimizable_type(%Company{}), do: :service
end
