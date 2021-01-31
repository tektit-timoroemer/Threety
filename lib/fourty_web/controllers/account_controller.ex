defmodule FourtyWeb.AccountController do
  use FourtyWeb, :controller

  alias Fourty.Accounting
  alias Fourty.Accounting.Account

  def index_client(conn, %{"client_id" => client_id}) do
    accounts = Accounting.list_accounts(client_id)
    balances = Accounting.load_all_balances()
    render(conn, "index.html", accounts: accounts, balances: balances)    
  end

  def index(conn, _params) do
    accounts = Accounting.list_accounts()
    balances = Accounting.load_all_balances()
    render(conn, "index.html", accounts: accounts, balances: balances)
  end

  def new(conn, _params) do
    account = %Account{}
    changeset = Accounting.change_account(account)
    render(conn, "new.html", account: account, changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    case Accounting.create_account(account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: Routes.account_path(conn, :show, account))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounting.get_account!(id)
    render(conn, "show.html", account: account)
  end

  def edit(conn, %{"id" => id}) do
    account = Accounting.get_account!(id)
    changeset = Accounting.change_account(account)
    render(conn, "edit.html", account: account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounting.get_account!(id)

    case Accounting.update_account(account, account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: Routes.account_path(conn, :show, account))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", account: account, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounting.get_account!(id)
    {:ok, _account} = Accounting.delete_account(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: Routes.account_path(conn, :index))
  end
end
