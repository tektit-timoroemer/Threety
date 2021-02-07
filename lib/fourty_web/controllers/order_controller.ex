defmodule FourtyWeb.OrderController do
  use FourtyWeb, :controller

  alias Fourty.Clients
  alias Fourty.Clients.Order

  def index(conn, _params) do
    orders = Clients.list_orders()
    heading = Gettext.dgettext(FourtyWeb.Gettext, "orders", "index")
    render(conn, "index.html", orders: orders, heading: heading)
  end

  def index_project(conn, _params) do
    orders = Clients.list_orders()
    render(conn, "index.html", orders: orders)
  end

  def index_client(conn, _params) do
    orders = Clients.list_orders()
    render(conn, "index.html", orders: orders)
  end

  def index_account(conn, _params) do
    orders = Clients.list_orders()
    render(conn, "index.html", orders: orders)
  end

  def new(conn, params) do
    changeset = Ecto.Changeset.cast(%Order{}, params, [:project_id])
    order = Ecto.Changeset.apply_changes(changeset)
    |> Fourty.Repo.preload(project: [:client])
    render(conn, "new.html", order: order, changeset: changeset)
  end

  def create(conn, %{"order" => order_params}) do
    case Clients.create_order(order_params) do
      {:ok, order} ->
        conn
        |> put_flash(:info, "Order created successfully.")
        |> redirect(to: Routes.order_path(conn, :show, order))
      {:error, %Ecto.Changeset{} = changeset} ->
        order = Ecto.Changeset.apply_changes(changeset)
        |> Fourty.Repo.preload(project: [:client])
        render(conn, "new.html", order: order, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    order = Clients.get_order!(id)
    render(conn, "show.html", order: order)
  end

  def edit(conn, %{"id" => id}) do
    order = Clients.get_order!(id)
    changeset = Clients.change_order(order)
    render(conn, "edit.html", order: order, changeset: changeset)
  end

  def update(conn, %{"id" => id, "order" => order_params}) do
    order = Clients.get_order!(id)

    case Clients.update_order(order, order_params) do
      {:ok, order} ->
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: Routes.order_path(conn, :show, order))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", order: order, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Clients.get_order!(id)
    {:ok, _order} = Clients.delete_order(order)

    conn
    |> put_flash(:info, "Order deleted successfully.")
    |> redirect(to: Routes.order_path(conn, :index))
  end
end
