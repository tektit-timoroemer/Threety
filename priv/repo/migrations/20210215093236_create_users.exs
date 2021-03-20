defmodule Fourty.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password_encrypted, :string
      add :rate, :integer
      add :role, :integer
      add :attempts_no, :integer
      add :last_attempt, :naive_datetime, null: true
      timestamps()
    end
    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end

end
