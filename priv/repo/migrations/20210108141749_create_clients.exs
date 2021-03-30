defmodule Fourty.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :label, :string, null: false
      timestamps()
    end

    create unique_index(:clients, [:label])
  end
end
