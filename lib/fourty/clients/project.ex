defmodule Fourty.Clients.Project do
  @moduledoc """
  The Project schema:

  `name` should be unique for each `client` 
  and should not contain any unnecessary whitespace.

  There can be 0 to n projects per `client`.

  date_start should be before date_end. ### to do ###

  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, Fourty.TypeTrimmedString
    field :date_start, :date
    field :date_end, :date
    field :visible, :boolean, default: true
    belongs_to :client, Fourty.Clients.Client
    has_many :accounts, Fourty.Accounting.Account
    has_many :visible_accounts, Fourty.Accounting.Account, where: [visible: true]
    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :date_start, :date_end, :visible, :client_id])
    |> validate_required([:name, :client_id])
    |> Fourty.Validations.validate_date_sequence(:date_start, :date_end)
    |> assoc_constraint(:client)
    |> unique_constraint(:name, name: :projects_client_id_name_index)
  end
end
