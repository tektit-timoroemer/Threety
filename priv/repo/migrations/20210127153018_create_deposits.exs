defmodule Fourty.Repo.Migrations.CreateDeposits do
  use Ecto.Migration

  def change do
    create table(:deposits) do
      add :amount_cur, :integer
      add :amount_dur, :integer
      add :description, :string
      add :account_id, references(:accounts, on_delete: :delete_all)
      timestamps()
    end
    create index(:deposits, [:account_id, :inserted_at])
  end
end
