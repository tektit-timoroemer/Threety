defmodule Fourty.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :date_start, :date
      add :date_end, :date
      add :visible, :bool
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      timestamps()
    end
    create unique_index(:accounts, [:project_id, :name])
  end
end
