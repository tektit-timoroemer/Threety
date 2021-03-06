defmodule Fourty.Repo.Migrations.CreateMissingRefs do
  use Ecto.Migration

  def up do

    alter table(:withdrwls) do
      add_if_not_exists(:work_item_id, references(:work_items), null: false)
    end

    alter table(:work_items) do
      add_if_not_exists(:user_id, references(:users), null: false)
    end

  end

  def down do
 
    alter table(:work_items) do
      remove_if_exists(:user_id, references(:users))
    end
 
    alter table(:withdrwls) do
      remove_if_exists(:work_item_id, references(:work_items))
    end

  end

end
