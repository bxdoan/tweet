defmodule Tweet.Repo do
  use Ecto.Repo,
    otp_app: :tweet,
    adapter: Ecto.Adapters.Postgres
end
