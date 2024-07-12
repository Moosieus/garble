defmodule Garble.Commonvoice do
  use Ecto.Schema

  schema "commonvoice" do
    field(:path, :string)
    field(:converted, :boolean)
  end
end
