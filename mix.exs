defmodule Thevis.MixProject do
  use Mix.Project

  def project do
    [
      app: :thevis,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Thevis.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix core
      {:phoenix, "~> 1.8.1"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},

      # Assets
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},

      # Background jobs
      {:oban, "~> 2.17"},

      # Database & Vector Store
      {:pgvector, "~> 0.3.1"},

      # HTTP & API
      {:req, "~> 0.5"},
      {:jason, "~> 1.2"},

      # Configuration & Utilities
      {:nimble_options, "~> 1.0"},
      {:gettext, "~> 0.26"},

      # Security & Encryption
      {:cloak_ecto, "~> 1.2"},

      # PDF Generation
      {:pdf_generator, "~> 0.6.2"},

      # Email (optional, for notifications)
      {:swoosh, "~> 1.16"},

      # Telemetry
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},

      # Deployment
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},

      # Testing
      {:lazy_html, ">= 0.1.0", only: :test},
      {:ex_machina, "~> 2.7", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:stream_data, "~> 0.6", only: :test},

      # Documentation
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},

      # Optional: Data pipelines (for future use)
      {:gen_stage, "~> 1.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind thevis", "esbuild thevis"],
      "assets.deploy": [
        "tailwind thevis --minify",
        "esbuild thevis --minify",
        "phx.digest"
      ],
      precommit: ["compile --warning-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
