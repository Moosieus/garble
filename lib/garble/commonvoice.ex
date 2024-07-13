defmodule Garble.Commonvoice do
  use Ecto.Schema

  schema "commonvoice" do
    field(:path, :string)
    field(:converted, :boolean)
    field(:failed, :boolean)
  end
end
