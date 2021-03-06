defmodule FourtyWeb.WorkItemController do
  use FourtyWeb, :controller

  alias Fourty.Costs
  alias Fourty.Costs.WorkItem

  def index(conn, _params) do
    work_items = Costs.list_work_items()
    render(conn, "index.html", work_items: work_items)
  end

  def new(conn, _params) do
    changeset = Costs.change_work_item(%WorkItem{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"work_item" => work_item_params}) do
    case Costs.create_work_item(work_item_params) do
      {:ok, work_item} ->
        conn
        |> put_flash(:info, "Work item created successfully.")
        |> redirect(to: Routes.work_item_path(conn, :show, work_item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    work_item = Costs.get_work_item!(id)
    render(conn, "show.html", work_item: work_item)
  end

  def edit(conn, %{"id" => id}) do
    work_item = Costs.get_work_item!(id)
    changeset = Costs.change_work_item(work_item)
    render(conn, "edit.html", work_item: work_item, changeset: changeset)
  end

  def update(conn, %{"id" => id, "work_item" => work_item_params}) do
    work_item = Costs.get_work_item!(id)

    case Costs.update_work_item(work_item, work_item_params) do
      {:ok, work_item} ->
        conn
        |> put_flash(:info, "Work item updated successfully.")
        |> redirect(to: Routes.work_item_path(conn, :show, work_item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", work_item: work_item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    work_item = Costs.get_work_item!(id)
    {:ok, _work_item} = Costs.delete_work_item(work_item)

    conn
    |> put_flash(:info, "Work item deleted successfully.")
    |> redirect(to: Routes.work_item_path(conn, :index))
  end
end
