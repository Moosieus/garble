defmodule Mix.Tasks.Prepare do
  @moduledoc "Walk the commonvoice folder and populate the sqlite database."
  use Mix.Task

  require Logger

  def run([directory]) do
    Mix.Task.run("app.start")

    Garble.Repo.query!("DELETE FROM commonvoice", [])

    directory
    |> Path.expand()
    |> Garble.Files.recursive_stream()
    |> Stream.chunk_every(1000)
    |> Stream.map(&insert/1)
    |> Stream.run()
  end

  defp insert(paths) when is_list(paths) do
    values =
      paths
      |> Enum.map(&Path.absname/1)
      |> Enum.map(&~s[('#{&1}')])
      |> Enum.join(", ")

    sql = ~s[INSERT INTO commonvoice (path) VALUES #{values}]

    Garble.Repo.query!(sql, [])
  end
end
