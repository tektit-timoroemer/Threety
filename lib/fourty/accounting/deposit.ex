defmodule Fourty.Accounting.Deposit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deposits" do
    field :amount_cur, Fourty.TypeCurrency, default: nil
    field :amount_dur, Fourty.TypeDuration, default: nil
    field :description, :string
    belongs_to :account, Fourty.Accounting.Account 
    timestamps()
  end

  @doc false
  def changeset(deposit, attrs) do
    deposit
    |> cast(attrs, [:amount_dur, :amount_cur, :description])
    |> validate_required([:description])
    |> Fourty.Validations.validate_at_least_one([:amount_cur, :amount_dur])
  end
end
