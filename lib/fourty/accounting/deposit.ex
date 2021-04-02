defmodule Fourty.Accounting.Deposit do
  @moduledoc """

  The Deposit schema describes any kind of deposit to the related
  account. Additional, related/associated records may document further
  information.

  A deposit is fixed to an account, other relations/associations are
  optional but if one is given, it can only be a single one.

  ## Fields

    - amount_cur: An amount of currency

    - amount_dur: An amount of duration

    - label: Optional information about the transaction

  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Fourty.Validations

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
    |> validate_required([:account_id])
    |> assoc_constraint(:account)
    |> assoc_constraint(:order)
    |> Validations.validate_at_least_one([:amount_cur, :amount_dur])
    |> Validations.validate_at_most_one([:order_id])
  end
end
 