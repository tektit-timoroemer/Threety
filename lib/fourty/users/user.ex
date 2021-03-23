defmodule Fourty.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fourty.Validations

  # general schema to use for creating users
  # - for login, use Fourty.Users.Login
  # - to update passwords, use Fourty.Users.EditPW

  schema "users" do
    field :username, Fourty.TypeTrimmedString
    field :email, :string
    field :password_encrypted, :string
    field :password, Fourty.TypeTrimmedString, virtual: true
    field :password_confirmation, Fourty.TypeTrimmedString, virtual: true
    field :rate, Fourty.TypeCurrency
    field :role, :integer, default: 0
    has_many :work_items, Fourty.Costs.WorkItem
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :rate,
       :role,
       :password, :password_confirmation])
    |> validate_required([:username, :email, :role])
    |> validate_number(:rate, greater_than: 0)
    |> validate_format(:email, ~r/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/)
    |> Validations.validate_password(:password)
    |> validate_confirmation(:password)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> put_encrypted_password()
  end

  defp put_encrypted_password(%{valid?: true, changes: %{password: pw}} = changeset) do
    put_change(changeset, :password_encrypted, Argon2.hash_pwd_salt(pw))
  end

  defp put_encrypted_password(changeset) do
    changeset
  end

end
