defmodule FourtyWeb.WithdrwlController do
  use FourtyWeb, :controller

  alias Fourty.Accounting
  alias Fourty.Accounting.Withdrwl

  def index_account(conn, %{"account_id" => account_id}) do
    withdrwls = Accounting.list_withdrwls(account_id: account_id)
    account = Fourty.Accounting.get_account_solo!(account_id)
    heading = dgettext("withdrwls", "index_account",
      name: account.name)
    render(conn, "index.html", withdrwls: withdrwls, heading: heading)
  end

  def new(conn, _params) do
    changeset = Accounting.change_withdrwl(%Withdrwl{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"withdrwl" => withdrwl_params}) do
    case Accounting.create_withdrwl(withdrwl_params) do
      {:ok, withdrwl} ->
        conn
        |> put_flash(:info, dgettext("withdrwls", "create success"))
        |> redirect(to: Routes.withdrwl_path(conn, :show, withdrwl))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    withdrwl = Accounting.get_withdrwl!(id)
    render(conn, "show.html", withdrwl: withdrwl)
  end

  def edit(conn, %{"id" => id}) do
    withdrwl = Accounting.get_withdrwl!(id)
    changeset = Accounting.change_withdrwl(withdrwl)
    render(conn, "edit.html", withdrwl: withdrwl, changeset: changeset)
  end

  def update(conn, %{"id" => id, "withdrwl" => withdrwl_params}) do
    withdrwl = Accounting.get_withdrwl!(id)
    case Accounting.update_withdrwl(withdrwl, withdrwl_params) do
      {:ok, withdrwl} ->
        conn
        |> put_flash(:info, dgettext("withdrwls", "update success"))
        |> redirect(to: Routes.withdrwl_path(conn, :show, withdrwl))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", withdrwl: withdrwl, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    withdrwl = Accounting.get_withdrwl!(id)
    {:ok, _withdrwl} = Accounting.delete_withdrwl(withdrwl)

    conn
    |> put_flash(:info, dgettext("withdrwls", "delete success"))
    |> redirect(to: Routes.withdrwl_path(conn, :index))
  end
end
