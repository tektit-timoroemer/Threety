defmodule FourtyWeb.DepositController do
  use FourtyWeb, :controller

  alias Fourty.Accounting
  alias Fourty.Accounting.Deposit

  def index_account(conn, %{"account_id" => account_id}) do
    deposits = Accounting.list_deposits(account_id)
    account = Fourty.Accounting.get_account_solo!(account_id)
    heading = Gettext.dgettext(FourtyWeb.Gettext, "deposits", "index_account",
      name: account.name)
    render(conn, "index.html", deposits: deposits, heading: heading)
  end

  def new(conn, params) do
    changeset = Ecto.Changeset.cast(%Deposit{}, params, [:order_id])
    deposit = Ecto.Changeset.apply_changes(changeset)
    |> Fourty.Repo.preload(order: [project: [:client]])
    changeset = Ecto.Changeset.change(changeset, deposit.order)
    accounts = Accounting.get_accounts(deposit.order.project.id)
    render(conn, "new.html", changeset: changeset, deposit: deposit,
      accounts: accounts)
  end

  def create(conn, %{"deposit" => deposit_params}) do
    case Accounting.create_deposit(deposit_params) do
      {:ok, deposit} ->
        conn
        |> put_flash(:info, "Deposit created successfully.")
        |> redirect(to: Routes.deposit_path(conn, :show, deposit))
      {:error, %Ecto.Changeset{} = changeset} ->
        deposit = Ecto.Changeset.apply_changes(changeset)
        |> Fourty.Repo.preload(order: [project: [:client]])
        accounts = Accounting.get_accounts(deposit.order.project.id)
        render(conn, "new.html", changeset: changeset, deposit: deposit,
          accounts: accounts)
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
        |> put_flash(:info, "Deposit updated successfully.")
        |> redirect(to: Routes.deposit_path(conn, :show, deposit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", deposit: deposit, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    deposit = Accounting.get_deposit!(id)
    {:ok, _deposit} = Accounting.delete_deposit(deposit)

    conn
    |> put_flash(:info, "Deposit deleted successfully.")
    |> redirect(to: Routes.deposit_path(conn, :index))
  end
end
