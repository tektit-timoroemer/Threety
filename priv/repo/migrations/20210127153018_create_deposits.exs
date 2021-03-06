defmodule Fourty.Repo.Migrations.CreateDeposits do
  use Ecto.Migration

  def change do
    create table(:deposits) do
      add :amount_cur, :bigint
      add :amount_dur, :bigint
      add :description, :string
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :order_id, references(:orders, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:deposits, [:account_id, :inserted_at])
  end
end
