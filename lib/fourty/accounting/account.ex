defmodule Fourty.Accounting.Account do
	@moduledoc """
	The Account schema:

	`name` must be unique for each owner of the account, i.e. currently
	the `project` of a `client`. The `name` should not contain any
	unnecessary whitespace.

	There can be 0 to n accounts per `project`.

	date_start should be before date_end. ### to do ###

	"""
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, Fourty.TypeTrimmedString
    field :date_end, :date, default: nil
    field :date_start, :date, default: nil
    field :visible, :boolean, default: true
    field :balance_cur, Fourty.TypeCurrency, virtual: true, default: 0
    field :balance_dur, Fourty.TypeDuration, virtual: true, default: 0
    belongs_to :project, Fourty.Clients.Project
    has_many :withdrwls, Fourty.Accounting.Withdrwl
    has_many :deposits, Fourty.Accounting.Deposit
    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :date_start, :date_end, :visible, :project_id])
    |> validate_required([:name, :project_id])    
    |> Fourty.Validations.validate_date_sequence(:date_start, :date_end)
    |> assoc_constraint(:project)
    |> unique_constraint(:name, name: :accounts_project_id_name_index)
  end
end
