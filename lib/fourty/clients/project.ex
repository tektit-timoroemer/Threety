defmodule Fourty.Clients.Project do
  @moduledoc """
  The Project schema:

  `label` should be unique for each `client` 
  and should not contain any unnecessary whitespace.

  There can be 0 to n projects per `client`.

  date_start should be before date_end.

  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :label, Fourty.TypeTrimmedString
    field :date_start, :date
    field :date_end, :date
    field :visible, :boolean, default: true
    belongs_to :client, Fourty.Clients.Client
    has_many :orders, Fourty.Clients.Order
    has_many :accounts, Fourty.Accounting.Account
    has_many :visible_accounts, Fourty.Accounting.Account, where: [visible: true]
    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:label, :date_start, :date_end, :visible, :client_id])
    |> validate_required([:label, :client_id])
    |> Fourty.Validations.validate_date_sequence(:date_start, :date_end)
    |> assoc_constraint(:client)
    |> unique_constraint(:label, label: :projects_client_id_label_index)
  end
end
