# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :thevis,
  ecto_repos: [Thevis.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :thevis, ThevisWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ThevisWeb.ErrorHTML, json: ThevisWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Thevis.PubSub,
  live_view: [signing_salt: "VV7dSSNS"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :thevis, Thevis.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  thevis: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  thevis: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian configuration
# For development, we use a default secret. In production, set GUARDIAN_SECRET_KEY env var
config :thevis, Thevis.Guardian,
  issuer: "thevis",
  secret_key:
    {System, :get_env,
     [
       "GUARDIAN_SECRET_KEY",
       "ThPFmobEq82lpWytbAOyoakQEihAAOhDdMXgLrBz7YEeVNsOGNMSe//0Z8vh2QG"
     ]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
