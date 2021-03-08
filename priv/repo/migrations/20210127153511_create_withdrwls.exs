defmodule Fourty.Repo.Migrations.CreateWithdrwls do
  use Ecto.Migration

  def change do
    create table(:withdrwls) do
      add :amount_cur, :bigint
      add :amount_dur, :bigint
      add :description, :string
      add :account_id, references(:accounts, on_delete: :restrict), null: false
      # add :work_item_id, references(:work_items, on_delete: :restrict), null: false
      # when table :work_items is available
      timestamps()
    end

    create index(:withdrwls, [:account_id, :inserted_at])
  end
end
