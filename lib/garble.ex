defmodule Garble do
  @moduledoc """
  Documentation for `Garble`.
  """

  @threads :erlang.system_info(:logical_processors_available)

  def main(input_dir) do
    input_dir
    |> ls_stream()
    |> Flow.from_enumerable()
    |> Flow.partition(stages: @threads)
    |> Flow.map(&maybe_compress/1)
    |> Flow.run()
  end

  defp maybe_compress({clip_path, :regular}) when is_binary(clip_path) do
    compress(clip_path)
  end

  defp maybe_compress(_) do
    nil
  end

  def compress(clip_path) when is_binary(clip_path) do
    basename = Path.basename(clip_path)

    pipe_format = "-f codec2"

    codec2_args =
      [
        "-vn",
        ["-loglevel", "quiet"],
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
        ["-loglevel", "quiet"],
        ["-c:a", "libmp3lame"],
        ["-q:a", "0"],
        ["-threads", "1"]
      ]
      |> List.flatten()
      |> Enum.join(" ")

    cmd =
      ~s[ffmpeg -i "#{clip_path}" #{codec2_args} - | ffmpeg #{pipe_format} -i - #{mp3_args} -y "./priv/output/#{basename}"]

    System.shell(cmd)
  end

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
  end
end
