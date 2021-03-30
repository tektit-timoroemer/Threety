defmodule Fourty.Clients.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :date_eff, :date
    field :amount_cur, Fourty.TypeCurrency
    field :amount_dur, Fourty.TypeDuration
    field :label, :string
    field :sum_cur, Fourty.TypeCurrency, virtual: true, default: 0
    field :sum_dur, Fourty.TypeDuration, virtual: true, default: 0
    belongs_to :project, Fourty.Clients.Project
    has_many :deposits, Fourty.Accounting.Deposit
    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:date_eff, :amount_cur, :amount_dur, :label, :project_id])
    |> validate_required([:project_id, :label])
    |> assoc_constraint(:project)
  end
end
