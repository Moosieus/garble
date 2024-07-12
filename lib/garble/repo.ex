defmodule Garble.Repo do
  use Ecto.Repo,
    otp_app: :garble,
    adapter: Ecto.Adapters.SQLite3
end
