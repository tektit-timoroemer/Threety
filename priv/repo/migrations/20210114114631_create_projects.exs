defmodule Fourty.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :date_start, :date
      add :date_end, :date
      add :visible, :bool
      add :client_id, references(:clients, on_delete: :delete_all)
      timestamps()
    end
    create unique_index(:projects, [:client_id, :name])

  end
end
