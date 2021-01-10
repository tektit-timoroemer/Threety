defmodule Fourty.Clients.Client do
  @moduledoc """
  The Clients schema:

  `name` should be unique and should not contain any unnecessary whitespace.

  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :name, Fourty.TrimmedString
    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
