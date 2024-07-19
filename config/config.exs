import Config

config :garble,
  ecto_repos: [Garble.Repo]

config :garble, Garble.Repo,
  hostname: "localhost",
  database: "garble_repo.db",
  username: "user",
  password: "pass",
  log: false
