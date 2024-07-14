defmodule Garble.MixProject do
  use Mix.Project

  def project do
    [
      app: :garble,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Garble.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:flow, "~> 1.0"},
      {:dirent, git: "https://github.com/moosieus/erlang-dirent.git", branch: "otp-26-fix"},
      {:ecto_sql, "~> 3.0"},
      {:ecto_sqlite3, "~> 0.16"}
    ]
  end
end
