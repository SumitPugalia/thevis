defmodule Thevis.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    base_children = [
      ThevisWeb.Telemetry,
      Thevis.Repo,
      {Oban, Application.get_env(:thevis, Oban)},
      {DNSCluster, query: Application.get_env(:thevis, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Thevis.PubSub},
      ThevisWeb.Endpoint
    ]

    children =
      if Application.get_env(:thevis, :env) == :test do
        base_children
      else
        List.insert_at(base_children, 3, Thevis.Automation.SchedulerBoot)
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Thevis.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ThevisWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
