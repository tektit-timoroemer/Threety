defmodule Fourty.Clients.Client do
  @moduledoc """

  The Clients schema holds information about the clients in the system:
  at this time, this information consists only of the label (string)
  which can be used to identify a specific client, for example by name.

  For each client, you may add one or more `projects`.

  ## Fields

    - label: must be a unique identifier of the client record. Any
    leading and trailing as well as duplicate whitespace characters
    will be removed before the label is stored in the system.

  ## Notes

    - visible_projects are those projects which have the visible flag
    set.

  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :label, Fourty.TypeTrimmedString
    has_many :projects, Fourty.Clients.Project
    has_many :visible_projects, Fourty.Clients.Project, where: [visible: true]
    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:label])
    |> validate_required([:label])
    |> unique_constraint(:label)
  end
end
