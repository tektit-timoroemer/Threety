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
    field :name, Fourty.TrimmedString
    field :date_start, :date
    field :date_end, :date
    field :visible, :boolean, default: true
    belongs_to :client, Fourty.Clients.Client
    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :date_start, :date_end, :visible])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :projects_client_id_name_index)
  end
end
