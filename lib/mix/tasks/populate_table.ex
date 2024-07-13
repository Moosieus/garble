defmodule Mix.Tasks.PopulateTable do
  @moduledoc "Walk the commonvoice folder and populate the sqlite database."
  use Mix.Task

  require Logger

  def run(_) do
    Mix.Task.run("app.start")

    "priv/commonvoice/clips"
    |> Garble.ls_stream()
    |> Stream.chunk_every(1000)
    |> Stream.map(&insert/1)
    |> Stream.run()
  end

  defp insert(paths) when is_list(paths) do
    values =
      paths
      |> Enum.map(&~s[('#{&1}')])
      |> Enum.join(", ")

    sql = ~s[INSERT INTO commonvoice (path) VALUES #{values}]

    Garble.Repo.query!(sql, [])
  end
end
