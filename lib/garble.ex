defmodule Garble do
  @moduledoc """
  Documentation for `Garble`.
  """

  import Ecto.Query

  require Logger

  @doc """
  Runs the file at `path` through codec2 and logs progress in the db with `id`.
  """
  def compress_with_progress({id, path}, relative_path)
      when is_integer(id) and is_binary(path) and is_binary(relative_path) do
    case compress(path, relative_path) do
      :ok ->
        Garble.Repo.update_all(
          from(c in Garble.Commonvoice, where: c.id == ^id),
          set: [converted: true]
        )

      {:error, _} ->
        Garble.Repo.update_all(
          from(c in Garble.Commonvoice, where: c.id == ^id),
          set: [failed: true]
        )

        Logger.warning("#{id} #{path} failed to convert.")
    end
  end

  # need to mirror the former folder structure somewhere, and save the files as such.

  def compress(clip_path, relative_path, log_level \\ "quiet") when is_binary(clip_path) do
    save_path =
      clip_path
      |> (&Path.relative_to(&1, relative_path)).()
      |> (&Path.join("./priv", &1)).()

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

    save_path
    |> Path.dirname()
    |> File.mkdir_p!()

    cmd =
      ~s[ffmpeg -f mp3 -i "#{clip_path}" #{codec2_args} - | ffmpeg #{pipe_format} -i - #{mp3_args} -y "#{save_path}"]

    case System.shell(cmd) do
      {_, 0} -> :ok
      {col, 1} -> {:error, col}
    end
  end
end
