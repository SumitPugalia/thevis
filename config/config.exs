# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :thevis,
  ecto_repos: [Thevis.Repo],
  generators: [timestamp_type: :utc_datetime],
  env: Mix.env()

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

# AI/LLM configuration
config :thevis, Thevis.AI,
  adapter: Thevis.AI.OpenAIAdapter,
  api_key: {System, :get_env, ["OPENAI_API_KEY"]},
  model: "gpt-4o-mini",
  embedding_model: "text-embedding-3-small"

# Oban configuration
config :thevis, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10, scans: 10, reports: 5],
  repo: Thevis.Repo

# External Platform API Configuration
config :thevis, Thevis.Integrations.GitHub,
  api_token: {System, :get_env, ["GITHUB_API_TOKEN"]},
  api_url: "https://api.github.com",
  default_branch: "main"

config :thevis, Thevis.Integrations.Medium,
  api_token: {System, :get_env, ["MEDIUM_API_TOKEN"]},
  api_url: "https://api.medium.com/v1"

config :thevis, Thevis.Integrations.Blog,
  cms_type: {System, :get_env, ["BLOG_CMS_TYPE", "wordpress"]},
  api_url: {System, :get_env, ["BLOG_API_URL"]},
  api_key: {System, :get_env, ["BLOG_API_KEY"]},
  username: {System, :get_env, ["BLOG_USERNAME"]},
  # Contentful (when cms_type is "contentful")
  contentful_space_id: {System, :get_env, ["CONTENTFUL_SPACE_ID"]},
  contentful_environment_id: {System, :get_env, ["CONTENTFUL_ENVIRONMENT_ID", "master"]},
  contentful_content_type_id: {System, :get_env, ["CONTENTFUL_CONTENT_TYPE_ID", "blogPost"]},
  contentful_locale: {System, :get_env, ["CONTENTFUL_LOCALE", "en-US"]}

# NewsAPI.org (optional; set NEWS_API_KEY for crawl_news)
config :thevis, Thevis.Integrations.NewsApiClient, api_key: {System, :get_env, ["NEWS_API_KEY"]}

# Review platforms (GEO authority)
config :thevis, Thevis.Integrations.TrustpilotClient,
  api_key: {System, :get_env, ["TRUSTPILOT_API_KEY"]}

config :thevis, Thevis.Integrations.YelpClient, api_key: {System, :get_env, ["YELP_API_KEY"]}

config :thevis, Thevis.Integrations.GoogleBusinessClient,
  access_token: {System, :get_env, ["GOOGLE_BUSINESS_ACCESS_TOKEN"]}

# Directories / listings
config :thevis, Thevis.Integrations.CrunchbaseClient,
  api_key: {System, :get_env, ["CRUNCHBASE_API_KEY"]}

config :thevis, Thevis.Integrations.LinkedInCompanyClient,
  access_token: {System, :get_env, ["LINKEDIN_ACCESS_TOKEN"]}

config :thevis, Thevis.Integrations.ProductHuntClient,
  api_token: {System, :get_env, ["PRODUCT_HUNT_TOKEN"]}

# Social / professional
config :thevis, Thevis.Integrations.TwitterClient,
  bearer_token: {System, :get_env, ["TWITTER_BEARER_TOKEN"]}

config :thevis, Thevis.Integrations.FacebookClient,
  access_token: {System, :get_env, ["FACEBOOK_ACCESS_TOKEN"]}

# Community & Q&A
config :thevis, Thevis.Integrations.RedditClient,
  client_id: {System, :get_env, ["REDDIT_CLIENT_ID"]},
  client_secret: {System, :get_env, ["REDDIT_CLIENT_SECRET"]}

config :thevis, Thevis.Integrations.StackExchangeClient,
  api_key: {System, :get_env, ["STACK_EXCHANGE_KEY"]}

# G2, Capterra, Clutch, AlternativeTo, Quora, Hacker News: no API key required (profile URL or slug in settings)

config :thevis, Thevis.Integrations.Citations,
  enabled: true,
  citation_sources: [
    "scholar.google.com",
    "arxiv.org",
    "ieee.org",
    "acm.org"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
