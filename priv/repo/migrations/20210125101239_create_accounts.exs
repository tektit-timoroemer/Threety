defmodule Fourty.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :label, :string, null: false
      add :date_start, :date
      add :date_end, :date
      add :visible, :bool
      add :project_id, references(:projects), null: false
      timestamps()
    end

    create unique_index(:accounts, [:project_id, :label])
  end
end
