defmodule Garble.DB do
  import Ecto.Query

  require Logger

  def entries_stream() do
    Stream.resource(&init/0, &next/1, &finally/1)
  end

  def init() do
    from(
      c in Garble.Commonvoice,
      where: c.converted == false and c.failed == false,
      select: min(c.id)
    )
    |> Garble.Repo.one!()
  end

  defp next(counter) do
    query =
      from(
        c in Garble.Commonvoice,
        where: c.id > ^counter and c.converted == false and c.failed == false,
        order_by: [asc: c.id],
        select: {c.id, c.path},
        limit: 1000
      )

    case Garble.Repo.all(query) do
      [] -> {:halt, counter}
      paths -> {paths, counter + length(paths)}
    end
  end

  defp finally(counter) when is_integer(counter) do
    Logger.info("converted #{counter} samples.")
  end
end
