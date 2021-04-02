defmodule Fourty.Clients.Project do
  @moduledoc """

  The Project schema describes a project for the given client. There can
  be one or more projects per client and each project may be accounted
  for using one or more accounts.

  Project start and completion dates may be set for documentation
  purposes, however accounting will run separately, i.e. accounts for a
  given project may be used before the date_start or after date_end date
  - there is no connection between the date_start and date_end dates of
  the associated accounts.

  If a project is deleted, all related/associated orders and accounts
  will be deleted as well.

  ## Fields

    - label: the unique name or identifier of this project. This text
    must be unique for all projects of the given client. Any leading 
    and trailing as well as duplicate whitespace characters will be
    removed before the label is stored in the system.

    - date_start: This is for documentation purposes only: You can use
    this field to show the actual project start date. The date_start
    date must occur before the date_end date (if given).

    - date_end: This is for documentation purposes only: You can use
    this field to show the actual project completion date. The date_end
    date must occur on or after the date_start date.

    - visible: Clearing this flag will cause this project to be 
    omitted from any reports and listings.

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
