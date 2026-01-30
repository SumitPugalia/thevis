defmodule Thevis.Integrations do
  @moduledoc """
  The Integrations context for managing platform settings and external API integrations.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Integrations.PlatformSetting

  ## Platform Settings

  @doc """
  Returns the list of platform settings for a project.
  """
  def list_platform_settings(project_id, filters \\ %{}) do
    base_query = from(ps in PlatformSetting, where: ps.project_id == ^project_id)

    base_query
    |> apply_platform_filters(filters)
    |> order_by([ps], desc: ps.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single platform setting.
  """
  def get_platform_setting!(id), do: Repo.get!(PlatformSetting, id)

  @doc """
  Gets a platform setting by project and platform type.
  """
  def get_platform_setting_by_type(project_id, platform_type) do
    Repo.get_by(PlatformSetting, project_id: project_id, platform_type: platform_type)
  end

  @doc """
  Creates a platform setting.
  """
  def create_platform_setting(attrs \\ %{}) do
    %PlatformSetting{}
    |> PlatformSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a platform setting.
  """
  def update_platform_setting(%PlatformSetting{} = platform_setting, attrs) do
    platform_setting
    |> PlatformSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a platform setting.
  """
  def delete_platform_setting(%PlatformSetting{} = platform_setting) do
    Repo.delete(platform_setting)
  end

  @doc """
  Gets or creates a platform setting for a project.
  """
  def get_or_create_platform_setting(project_id, platform_type, default_settings \\ %{}) do
    case get_platform_setting_by_type(project_id, platform_type) do
      nil ->
        create_platform_setting(%{
          project_id: project_id,
          platform_type: platform_type,
          settings: default_settings
        })

      setting ->
        {:ok, setting}
    end
  end

  @doc """
  Resolves a config value for an integration module from application config.

  Supports:
  - `{System, :get_env, [key]}` → `System.get_env(key)`
  - `{System, :get_env, [key, default]}` → `System.get_env(key) || default`
  - binary → returned as-is
  - other → `default`

  Used by GitHub, Medium, BlogClient, NewsApiClient, and other API clients.
  """
  @spec get_config_value(module(), atom(), term()) :: binary() | term() | nil
  def get_config_value(module, key, default \\ nil) do
    config = Application.get_env(:thevis, module)

    if config do
      raw = Keyword.get(config, key, default)
      resolve_config_value(raw, default)
    else
      default
    end
  end

  @doc """
  Resolves API token for an integration module from application config.
  Convenience wrapper around `get_config_value(module, :api_token)`.
  """
  @spec get_api_token(module()) :: binary() | nil
  def get_api_token(module) do
    get_config_value(module, :api_token)
  end

  defp resolve_config_value({_system, :get_env, [key]}, _default), do: System.get_env(key)

  defp resolve_config_value({_system, :get_env, [key, default]}, _default),
    do: System.get_env(key) || default

  defp resolve_config_value(val, _default) when is_binary(val), do: val
  defp resolve_config_value(_, default), do: default

  defp apply_platform_filters(query, %{platform_type: platform_type}) do
    where(query, [ps], ps.platform_type == ^platform_type)
  end

  defp apply_platform_filters(query, %{is_active: is_active}) do
    where(query, [ps], ps.is_active == ^is_active)
  end

  defp apply_platform_filters(query, _), do: query
end
