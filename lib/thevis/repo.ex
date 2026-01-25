defmodule Thevis.Repo do
  use Ecto.Repo,
    otp_app: :thevis,
    adapter: Ecto.Adapters.Postgres
end
