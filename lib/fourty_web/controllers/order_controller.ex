defmodule FourtyWeb.OrderController do
  use FourtyWeb, :controller

  alias Fourty.Clients
  alias Fourty.Clients.Order

  def index(conn, _params) do
    orders = Clients.list_orders()
    order_sums = Clients.load_all_order_sums()
    heading = dgettext("orders", "index")
    render(conn, "index.html", orders: orders, order_sums: order_sums, heading: heading)
  end

  def index_project(conn, %{"project_id" => project_id}) do
    project = Clients.get_project!(project_id)
    orders = Clients.list_orders(client_id: project.client_id, project_id: project.id)
    order_sums = Clients.load_all_order_sums()

    heading =
      dgettext("orders", "index_project",
        label: List.first(List.first(orders).visible_projects).label
      )

    render(conn, "index.html", orders: orders, order_sums: order_sums, heading: heading)
  end

  def index_client(conn, %{"client_id" => client_id}) do
    orders = Clients.list_orders(client_id: client_id)
    order_sums = Clients.load_all_order_sums()
    heading = dgettext("orders", "index_client", label: List.first(orders).label)
    render(conn, "index.html", orders: orders, order_sums: order_sums, heading: heading)
  end

  def index_account(conn, %{"account_id" => account_id}) do
    orders = Clients.list_orders(account_id: account_id)
    order_sums = Clients.load_all_order_sums()

    heading =
      dgettext("orders", "index_account",
        label: List.first(List.first(List.first(orders).visible_projects).accounts).label
      )

    render(conn, "index.html", orders: orders, order_sums: order_sums, heading: heading)
  end

  def new(conn, params) do
    changeset = Ecto.Changeset.cast(%Order{}, params, [:project_id])

    order =
      Ecto.Changeset.apply_changes(changeset)
      |> Fourty.Repo.preload(project: [:client])

    render(conn, "new.html", order: order, changeset: changeset)
  end

  def create(conn, %{"order" => order_params}) do
    case Clients.create_order(order_params) do
      {:ok, order} ->
        conn
        |> put_flash(:info, dgettext("orders", "create_success"))
        |> redirect(to: Routes.order_path(conn, :show, order))

      {:error, %Ecto.Changeset{} = changeset} ->
        order =
          Ecto.Changeset.apply_changes(changeset)
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
        |> put_flash(:info, dgettext("orders", "update_success"))
        |> redirect(to: Routes.order_path(conn, :show, order))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", order: order, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Clients.get_order!(id)
    {:ok, _order} = Clients.delete_order(order)

    conn
    |> put_flash(:info, dgettext("orders", "delete_success"))
    |> redirect(to: Routes.order_path(conn, :index))
  end
end
