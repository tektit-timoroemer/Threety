defmodule Fourty.Accounting.Withdrwl do
  use Ecto.Schema
  import Ecto.Changeset

  schema "withdrwls" do
    field :amount_cur, Fourty.TypeCurrency, default: nil
    field :amount_dur, Fourty.TypeDuration, default: nil
    field :label, :string
    belongs_to :account, Fourty.Accounting.Account
    belongs_to :work_item, Fourty.Costs.WorkItem
    timestamps()
  end

  @doc false
  def changeset(withdrwl, attrs) do
    withdrwl
    |> cast(attrs, [:amount_dur, :amount_cur, :label, :account_id])
    |> validate_required([:label, :account_id])
    |> assoc_constraint(:account)
    |> assoc_constraint(:work_item)
    |> Fourty.Validations.validate_at_least_one([:amount_cur, :amount_dur])
  end
end
