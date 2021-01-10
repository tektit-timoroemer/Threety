defmodule Fourty.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :name, :string
    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    # must use string as attrs contains strings!
    a = Fourty.Helpers.trim_items(attrs, ["name"])
    client
    |> cast(a, [:name])
    |> validate_required([:name])
  end
end
