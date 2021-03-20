defmodule Fourty.Repo.Migrations.CreateWorkItems do
  use Ecto.Migration

  def change do
    create table(:work_items) do
      add :date_as_of, :date
      add :duration, :integer
      add :time_from, :time
      add :time_to, :time
      add :comments, :string
      add :sequence, :integer
#     add :user_id, references(:users), null: false
#     --- done in later migration (forward reference)
      add :withdrwl_id, references(:withdrwls, on_delete: :restrict), null: false
      timestamps()
    end

#    create unique_index(:work_items, [:user_id, :date_as_of, :sequence])
#    --- done in later migration (forward reference)
  end

end
