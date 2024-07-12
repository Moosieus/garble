defmodule Garble.Repo.Migrations.AddCommonvoiceTable do
  use Ecto.Migration

  def change do
    create table(:commonvoice) do
      add :path, :string
      add :converted, :boolean, default: false
    end

    create unique_index(:commonvoice, [:path], name: :path_uniq)
  end
end
