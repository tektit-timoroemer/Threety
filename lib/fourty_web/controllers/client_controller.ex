defmodule FourtyWeb.ClientController do
  use FourtyWeb, :controller

  alias Fourty.Clients
  alias Fourty.Clients.Client

  def index(conn, _params) do
    clients = Clients.list_clients()
    render(conn, "index.html", clients: clients)
  end

  def new(conn, _params) do
    changeset = Clients.change_client(%Client{})
    IO.inspect(changeset)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"client" => client_params}) do
    case Clients.create_client(client_params) do
      {:ok, client} ->
        conn
        |> put_flash(:info, dgettext("clients","create success"))
        |> redirect(to: Routes.client_path(conn, :show, client))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    client = Clients.get_client!(id)
    render(conn, "show.html", client: client)
  end

  def edit(conn, %{"id" => id}) do
    client = Clients.get_client!(id)
    changeset = Clients.change_client(client)
    render(conn, "edit.html", client: client, changeset: changeset)
  end

  def update(conn, %{"id" => id, "client" => client_params}) do
    client = Clients.get_client!(id)

    case Clients.update_client(client, client_params) do
      {:ok, _client} ->
        conn
        |> put_flash(:info, dgettext("clients","update success"))
        |> redirect(to: Routes.client_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", client: client, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    client = Clients.get_client!(id)
    {:ok, _client} = Clients.delete_client(client)

    conn
    |> put_flash(:info, dgettext("clients","delete success"))
    |> redirect(to: Routes.client_path(conn, :index))
  end
end
