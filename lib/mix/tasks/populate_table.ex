defmodule Mix.Tasks.PopulateTable do
  @moduledoc "Walk the commonvoice folder and populate the sqlite database."
  use Mix.Task

  require Logger

  def run(_) do
    Mix.Task.run("app.start")

    Logger.configure(level: :warn)

    "priv/commonvoice/clips"
    |> Garble.ls_stream()
    |> Stream.filter(&filter_regular/1)
    |> Stream.map(&tuple_to_binary/1)
    |> Stream.chunk_every(1000)
    |> Stream.map(&insert/1)
    |> Stream.run()
  end

  defp filter_regular({path, :regular}) when is_binary(path), do: true
  defp filter_regular(_), do: false

  defp tuple_to_binary({path, :regular}) when is_binary(path), do: path

  defp insert(paths) when is_list(paths) do
    values =
      paths
      |> Enum.map(&~s[('#{&1}')])
      |> Enum.join(", ")

    sql = ~s[INSERT INTO commonvoice (path) VALUES #{values}]

    Garble.Repo.query!(sql, [])
  end
end
