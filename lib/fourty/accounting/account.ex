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
    field :name, Fourty.TrimmedString
    field :date_end, :date
    field :date_start, :date
    field :visible, :boolean, default: true
    field :balance_cur, :integer, virtual: true, default: 0
    field :balance_dur, :integer, virtual: true, default: 0
    belongs_to :project, Fourty.Clients.Project
    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :date_start, :date_end, :visible])
    |> validate_required([:name])
    |> Fourty.Validations.validate_date_sequence(:date_start, :date_end)
    |> unique_constraint(:name, name: :accounts_project_id_name_index)
  end
end
