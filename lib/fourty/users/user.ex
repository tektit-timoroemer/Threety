defmodule Fourty.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fourty.Validations

  schema "users" do
    field :username, Fourty.TypeTrimmedString
    field :email, :string
    field :password_encrypted, :string
    field :password, Fourty.TypeTrimmedString, virtual: true
    field :password_confirmation, Fourty.TypeTrimmedString, virtual: true
    field :rate, Fourty.TypeCurrency
    field :role, :integer, default: 0
#   field :attempts_no, :integer, default: 0
#   field :last_attempt, :naive_datetime
    has_many :work_items, Fourty.Costs.WorkItem
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :rate,
#      :attempts_no, :last_attempt,
       :role,
       :password, :password_confirmation])
    |> validate_required([:username, :email, :role,
       :password, :password_confirmation])
    |> validate_number(:rate, greater_than_or_equal_to: 0)
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
