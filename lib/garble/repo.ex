defmodule Garble.Repo do
  use Ecto.Repo,
    otp_app: :garble,
    adapter: Ecto.Adapters.Postgres
end
