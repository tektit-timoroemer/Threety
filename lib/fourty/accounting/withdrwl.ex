defmodule Fourty.Accounting.Withdrwl do
  use Ecto.Schema
  import Ecto.Changeset

  schema "withdrwls" do
    field :amount_cur, Fourty.TypeCurrency, default: nil
    field :amount_dur, Fourty.TypeDuration, default: nil
    field :description, :string
    belongs_to :account, Fourty.Accounting.Account
    # belongs_to :tasks, Fourty.Users.Task
    timestamps()
  end

  @doc false
  def changeset(withdrwl, attrs) do
    withdrwl
    |> cast(attrs, [:amount_dur, :amount_cur, :description, :account_id])
    |> validate_required([:description, :account_id])
    |> assoc_constraint(:account)
    # |> assoc_constraint(:task)
    |> Fourty.Validations.validate_at_least_one([:amount_cur, :amount_dur])
  end
end
