defmodule Fourty.Clients.Client do
  @moduledoc """
  The Clients schema:

  `name` should be unique and 
  should not contain any unnecessary whitespace.

  There can be 0 to n projects per `client`.

  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :name, Fourty.TypeTrimmedString
    has_many :projects, Fourty.Clients.Project
    has_many :visible_projects, Fourty.Clients.Project, where: [visible: true]
    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
