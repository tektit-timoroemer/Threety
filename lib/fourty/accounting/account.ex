defmodule Fourty.Accounting.Account do
  @moduledoc """
  The Account schema:

  `label` must be unique for each owner of the account, i.e. currently
  the `project` of a `client`. The `label` should not contain any
  unnecessary whitespace.

  There can be 0 to n accounts per `project`.

  date_start should be before date_end.

  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :label, Fourty.TypeTrimmedString
    field :date_end, :date, default: nil
    field :date_start, :date, default: nil
    field :visible, :boolean, default: true
    field :balance_cur, Fourty.TypeCurrency, virtual: true, default: nil
    field :balance_dur, Fourty.TypeDuration, virtual: true, default: nil
    belongs_to :project, Fourty.Clients.Project
    has_many :withdrwls, Fourty.Accounting.Withdrwl
    has_many :deposits, Fourty.Accounting.Deposit
    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:label, :date_start, :date_end, :visible, :project_id])
    |> validate_required([:label, :project_id])
    |> Fourty.Validations.validate_date_sequence(:date_start, :date_end)
    |> assoc_constraint(:project)
    |> unique_constraint(:label, label: :accounts_project_id_label_index)
  end
end
