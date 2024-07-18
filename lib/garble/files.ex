defmodule Garble.Files do
  @moduledoc """
  File operations, namely `recursive_stream/1`.
  """

  require Logger

  @doc """
  Lists all `.mp3` files recursively in the directory.
  """
  def recursive_stream(directory) when is_binary(directory) do
    Stream.resource(
      fn ->
        {:ok, dir_ref} = :dirent.opendir(directory)

        [dir_ref]
      end,
      &walk/1,
      # not used because :dirent cleans up on GC
      fn _ -> :ok end
    )
  end

  defp walk([dir_ref | rest] = dir_refs) do
    case :dirent.readdir_type(dir_ref) do
      :finished ->
        {[], rest}

      {:error, reason} ->
        Logger.warning("error reading directory reference: #{inspect(reason)}")
        {[], dir_refs}

      {dir, :directory} ->
        {:ok, rec_ref} = :dirent.opendir(dir)
        {[], [rec_ref | dir_refs]}

      {name, :regular} ->
        case Path.extname(name) do
          ".mp3" ->
            {[List.to_string(name)], dir_refs}

          _ ->
            {[], dir_refs}
        end

    end
  end

  # no more directories
  defp walk([]), do: {:halt, []}
end
