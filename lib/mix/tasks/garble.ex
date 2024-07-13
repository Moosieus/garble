defmodule Mix.Tasks.Garble do
  use Mix.Task

  import Ecto.Query

  require Logger

  @threads :erlang.system_info(:logical_processors_available)

  def run(_) do
    Mix.Task.run("app.start")

    Logger.configure(level: :warn)

    Garble.paths_stream()
    |> Flow.from_enumerable()
    |> Flow.partition(stages: @threads)
    |> Flow.run()
  end
end
