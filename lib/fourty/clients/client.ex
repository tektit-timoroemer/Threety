defmodule Fourty.Clients.Client do
  @moduledoc """
  The Clients schema:

  `label` must be unique and 
  must not contain any unnecessary whitespace.

  There can be 0 to n projects per `client`.

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
