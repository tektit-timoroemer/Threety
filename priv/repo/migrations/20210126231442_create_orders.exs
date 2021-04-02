defmodule Fourty.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :date_eff, :date
      add :amount_cur, :bigint
      add :amount_dur, :bigint
      add :label, :string
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      timestamps()
    end
  end
end
