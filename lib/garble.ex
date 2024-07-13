defmodule Garble do
  @moduledoc """
  Documentation for `Garble`.
  """

  import Ecto.Query

  require Logger

  def compress_and_log({id, path}) when is_integer(id) and is_binary(path) do
    case compress(path) do
      :ok ->
        Garble.Repo.update_all(
          from(c in Garble.Commonvoice, where: c.id == ^id), set: [converted: true]
        )

      {:error, _} ->
        Garble.Repo.update_all(
          from(c in Garble.Commonvoice, where: c.id == ^id), set: [failed: true]
        )
        Logger.warning("#{id} #{path} failed to convert.")
    end
  end

  def compress(clip_path, log_level \\ "quiet") when is_binary(clip_path) do
    basename = Path.basename(clip_path)

    pipe_format = "-f codec2"

    codec2_args =
      [
        "-vn",
        ["-loglevel", log_level],
        "-c:a",
        "libcodec2",
        ["-mode", "3200"],
        ["-threads", "1"],
        pipe_format
      ]
      |> List.flatten()
      |> Enum.join(" ")

    mp3_args =
      [
        ["-loglevel", log_level],
        ["-c:a", "libmp3lame"],
        ["-q:a", "0"],
        ["-threads", "1"]
      ]
      |> List.flatten()
      |> Enum.join(" ")

    cmd =
      ~s[ffmpeg -f mp3 -i "#{clip_path}" #{codec2_args} - | ffmpeg #{pipe_format} -i - #{mp3_args} -y "./priv/output/#{basename}"]

    case System.shell(cmd) do
      {_, 0} -> :ok
      {col, 1} -> {:error, col}
    end
  end

  # Populate Table

  def ls_stream(target_path) when is_binary(target_path) do
    Stream.resource(
      fn ->
        {:ok, dir_ref} =
          target_path
          |> String.to_charlist()
          |> :dirent.opendir()

        dir_ref
      end,
      fn dir_ref ->
        case :dirent.readdir_type(dir_ref) do
          :finished ->
            {:halt, dir_ref}

          {:error, reason} ->
            {[{:error, reason}], dir_ref}

          {name, type} ->
            {[{List.to_string(name), type}], dir_ref}
        end
      end,
      # not used because :dirent cleans up on GC
      fn _ -> :ok end
    )
    |> Stream.filter(&filter_regular/1)
    |> Stream.map(&tuple_to_binary/1)
  end

  defp filter_regular({path, :regular}) when is_binary(path), do: true
  defp filter_regular(_), do: false

  defp tuple_to_binary({path, :regular}) when is_binary(path), do: path

  # Garble

  def paths_stream() do
    Stream.resource(&init/0, &next/1, &finally/1)
  end

  def init() do
    from(
      c in Garble.Commonvoice,
      where: c.converted == false and c.failed == false,
      select: min(c.id)
    ) |> Garble.Repo.one!()
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
