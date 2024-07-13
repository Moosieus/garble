defmodule Garble.Repo.Migrations.AddFailedColumn do
  use Ecto.Migration

  def change do
    alter table "commonvoice" do
      add :failed, :boolean, default: false
    end
  end
end
