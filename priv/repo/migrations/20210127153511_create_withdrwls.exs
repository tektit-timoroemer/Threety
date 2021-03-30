defmodule Fourty.Repo.Migrations.CreateWithdrwls do
  use Ecto.Migration

  def change do
    create table(:withdrwls) do
      add :amount_cur, :bigint
      add :amount_dur, :bigint
      add :label, :string
      add :account_id, references(:accounts, on_delete: :restrict), null: false
#     add :work_item_id, references(:work_items, on_delete: :restrict), null: false
#     --- done in later migration (forward reference)
      timestamps()
    end

    create index(:withdrwls, [:account_id, :inserted_at])
#   create index(:withdrwls, [:work_item_id, :inserted_at])
#     --- done in later migration (forward reference)
  end
end
