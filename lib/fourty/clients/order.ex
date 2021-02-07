defmodule Fourty.Clients.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :date_eff, :date
    field :amount_cur, Fourty.TypeCurrency
    field :amount_dur, Fourty.TypeDuration
    field :description, :string
    belongs_to :project, Fourty.Clients.Project
    has_many :deposits, Fourty.Accounting.Deposit
    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:date_eff, :amount_cur, :amount_dur, :description, :project_id])
    |> validate_required([:project_id])
    |> assoc_constraint(:project)
  end
end
