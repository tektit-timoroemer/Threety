defmodule Fourty.Accounting.Withdrawal do
  @moduledoc """

  The Withdrawal schema describes any kind of withdrawal from the
  related account. Additional, related/associated records may document
  further information.

  A Withdrawal is fixed to an account, other relations/associations are
  optional but if one is given, it can only be a single one.

  ## Fields

    - amount_cur: An amount of currency

    - amount_dur: An amount of duration

    - label: Optional information about the transaction

  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Fourty.Validations

  schema "withdrawals" do
    field :amount_cur, Fourty.TypeCurrency, default: nil
    field :amount_dur, Fourty.TypeDuration, default: nil
    field :label, :string
    belongs_to :account, Fourty.Accounting.Account
    belongs_to :work_item, Fourty.Costs.WorkItem
    timestamps()
  end

  @doc false
  def changeset(withdrawal, attrs) do
    withdrawal
    |> cast(attrs, [:amount_dur, :amount_cur, :label, :account_id, :work_item])
    |> validate_required([:account_id])
    |> assoc_constraint(:account)
    |> assoc_constraint(:work_item)
    |> Validations.validate_at_least_one([:amount_cur, :amount_dur])
    |> Validations.validate_exactly_one([:work_item])
  end
end
