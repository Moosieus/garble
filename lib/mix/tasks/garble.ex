defmodule Mix.Tasks.Garble do
  use Mix.Task

  require Logger

  @threads :erlang.system_info(:logical_processors_available)

  def run([relative_path]) do
    Mix.Task.run("app.start")

    relative_path = Path.expand(relative_path)

    Garble.DB.entries_stream()
    |> Flow.from_enumerable()
    |> Flow.partition(stages: @threads)
    |> Flow.map(&Garble.compress_with_progress(&1, relative_path))
    |> Flow.run()
  end
end
