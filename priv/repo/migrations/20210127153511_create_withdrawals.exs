defmodule Fourty.Repo.Migrations.CreateWithdrawals do
  use Ecto.Migration

  def change do
    create table(:withdrawals) do
      add :amount_cur, :bigint
      add :amount_dur, :bigint
      add :label, :string
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
#     add :work_item_id, references(:work_items)
      timestamps()
    end

    create index(:withdrawals, [:account_id, :inserted_at])
  end
end
