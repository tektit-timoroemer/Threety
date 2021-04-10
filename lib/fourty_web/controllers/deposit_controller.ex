defmodule FourtyWeb.DepositController do
  use FourtyWeb, :controller

  alias Fourty.Accounting
  alias Fourty.Accounting.Deposit

  def index_account(conn, %{"account_id" => account_id}) do
    deposits = Accounting.list_deposits(account_id: account_id)
    account = Accounting.get_account_solo!(account_id)
    heading = dgettext("deposits", "index_account", label: account.label)
    render(conn, "index.html", deposits: deposits, heading: heading)
  end

  def index_order(conn, %{"order_id" => order_id}) do
    deposits = Accounting.list_deposits(order_id: order_id)
    order = Fourty.Clients.get_order!(order_id)
    render(conn, "index_order.html", deposits: deposits, order: order)
  end

  def new(conn, _params) do
    conn
    |> put_flash(:info, "not yet implemented")
    |> redirect(to: Routes.session_path(conn, :index))
  end

  def new_order(conn, params) do
    changeset = Ecto.Changeset.cast(%Deposit{}, params, [:order_id])

    deposit =
      Ecto.Changeset.apply_changes(changeset)
      |> Fourty.Repo.preload(order: [project: [:client]])

    accounts = Accounting.get_accounts_for_project(deposit.order.project.id)
    render(conn, "new.html", changeset: changeset, deposit: deposit, accounts: accounts)
  end

  def create(conn, %{"deposit" => deposit_params}) do
    case Accounting.create_deposit(deposit_params) do
      {:ok, deposit} ->
        conn
        |> put_flash(:info, dgettext("deposits", "create_success"))
        |> redirect(to: Routes.deposit_path(conn, :show, deposit.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        deposit =
          Ecto.Changeset.apply_changes(changeset)
          |> Fourty.Repo.preload(order: [project: [:client]])
        accounts = Accounting.get_accounts_for_project(deposit.order.project.id)
        render(conn, "new.html", changeset: changeset, deposit: deposit, accounts: accounts)
    end
  end

  def show(conn, %{"id" => id}) do
    deposit = Accounting.get_deposit!(id)
    render(conn, "show.html", deposit: deposit)
  end

  def edit(conn, %{"id" => id}) do
    deposit = Accounting.get_deposit!(id)
    changeset = Accounting.change_deposit(deposit)
    render(conn, "edit.html", deposit: deposit, changeset: changeset)
  end

  def update(conn, %{"id" => id, "deposit" => deposit_params}) do
    deposit = Accounting.get_deposit!(id)

    case Accounting.update_deposit(deposit, deposit_params) do
      {:ok, deposit} ->
        conn
        |> put_flash(:info, dgettext("deposits", "update_success"))
        |> redirect(to: Routes.deposit_path(conn, :show, deposit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", deposit: deposit, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    deposit = Accounting.get_deposit!(id)
    {:ok, _deposit} = Accounting.delete_deposit(deposit)

    conn
    |> put_flash(:info, dgettext("deposits", "delete_success"))
    |> redirect(to: Routes.deposit_path(conn, :index_account, deposit.account_id))
  end
end
