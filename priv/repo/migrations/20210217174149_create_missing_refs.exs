defmodule Fourty.Repo.Migrations.CreateMissingRefs do
  use Ecto.Migration

  def up do

    alter table(:withdrawals) do
      add_if_not_exists(:work_item_id, references(:work_items))
    end
    create index(:withdrawals, [:work_item_id])


    alter table(:work_items) do
      add_if_not_exists(:user_id, references(:users), null: false)
    end
    create unique_index(:work_items, [:user_id, :date_as_of, :sequence])

  end

  def down do
 
    drop_if_exists index(:withdrawals, [:work_item_id])
    alter table(:work_items) do
      remove_if_exists(:user_id, references(:users))
    end
 
    drop_if_exists index(:work_items, [:user_id, :date_as_of, :sequence])
    alter table(:withdrawals) do
      remove_if_exists(:work_item_id, references(:work_items))
    end

  end

end
