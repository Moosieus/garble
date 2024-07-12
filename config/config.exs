import Config

config :garble,
ecto_repos: [Garble.Repo]

config :garble, Garble.Repo,
  database: "garble_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"
