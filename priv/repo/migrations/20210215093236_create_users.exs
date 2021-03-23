defmodule Fourty.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password_encrypted, :string
      add :rate, :integer
      add :role, :integer
      timestamps()
    end
    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end

end
