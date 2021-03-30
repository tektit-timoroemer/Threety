defmodule Fourty.Accounting.Deposit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deposits" do
    field :amount_cur, Fourty.TypeCurrency, default: nil
    field :amount_dur, Fourty.TypeDuration, default: nil
    field :label, :string
    belongs_to :account, Fourty.Accounting.Account
    belongs_to :order, Fourty.Clients.Order
    timestamps()
  end

  @doc false
  def changeset(deposit, attrs) do
    deposit
    |> cast(attrs, [:amount_dur, :amount_cur, :label, :account_id, :order_id])
    |> validate_required([:label, :account_id, :order_id])
    |> assoc_constraint(:account)
    |> assoc_constraint(:order)
    |> Fourty.Validations.validate_at_least_one([:amount_cur, :amount_dur])
  end
end
