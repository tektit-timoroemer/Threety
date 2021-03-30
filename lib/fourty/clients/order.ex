defmodule Fourty.Clients.Order do
  @moduledoc """

  The Order schema describes an order for a given project. From a single
  order, you can make one or more deposits to the same or to different
  accounts.

  ## Fields

    - date_eff: the date on which the order becomes effective. This 
    permits you to document the actual placement of the order once you
    received a written confirmation. The field is therefore optional.

    - amount_cur: the amount - in currency units - of the order. For
    example, if the order is of 10,000.00 Euros, amount_cur would be set
    to 1000000.

    - amount_dur: if you want to track the duration spent on a project,
    you can set the amount of time planned to fulfill this order here
    (in internal units of time).

    - label: is a string field which must be used to give the order a
    descriptive name or to document otherwise which order this is.

    - sum_cur: is used internally and holds the accumulated amount of
    money spent for this order.

    - sum_dur: is used internally and holds the accumulated amount of
    time spent for this order.

    - project_id: points to the project for which this order is placed
    for.

  """
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
