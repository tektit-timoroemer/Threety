defmodule Fourty.Repo.Migrations.CreateWithdrwls do
  use Ecto.Migration

  def change do
    create table(:withdrwls) do
      add :amount_cur, :integer
      add :amount_dur, :integer
      add :description, :string
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      # add :task_id, references(:tasks, on_delete: :delete_all), null: false
      timestamps()
    end
    # create index(:withdrwls, [:account_id, :inserted_at])
  end
end
