defmodule FourtyWeb.AccountController do
  use FourtyWeb, :controller

  alias Fourty.Accounting
  alias Fourty.Accounting.Account

  def index(conn, _params) do
    accounts = Accounting.list_accounts()
    balances = Accounting.load_all_balances()
    heading = dgettext("accounts", "index")
    render(conn, "index.html", accounts: accounts, balances: balances, heading: heading)
  end

  def index_client(conn, %{"client_id" => client_id}) do
    accounts = Accounting.list_accounts(client_id)
    balances = Accounting.load_all_balances()
    heading = dgettext("accounts", "index_client", label: List.first(accounts).label)
    render(conn, "index.html", accounts: accounts, balances: balances, heading: heading)
  end

  def index_project(conn, %{"project_id" => project_id}) do
    project = Fourty.Clients.get_project!(project_id)
    accounts = Accounting.list_accounts(project.client_id, project.id)
    balances = Accounting.load_all_balances()
    heading =
      dgettext("accounts", "index_project",
        label: List.first(List.first(accounts).visible_projects).label
      )
    render(conn, "index.html", accounts: accounts, balances: balances, heading: heading)
  end

  def new(conn, params) do
    changeset = Ecto.Changeset.cast(%Account{}, params, [:project_id])
    account = Ecto.Changeset.apply_changes(changeset)
      |> Fourty.Repo.preload(project: [:client])
    render(conn, "new.html", account: account, changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    case Accounting.create_account(account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, dgettext("accounts", "create_success"))
        |> redirect(to: Routes.account_path(conn, :show, account))

      {:error, %Ecto.Changeset{} = changeset} ->
        account =
          Ecto.Changeset.apply_changes(changeset)
          |> Fourty.Repo.preload(project: [:client])

        render(conn, "new.html", account: account, changeset: changeset)
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
        |> put_flash(:info, dgettext("accounts", "update_success"))
        |> redirect(to: Routes.account_path(conn, :show, account))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", account: account, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounting.get_account!(id)
    {:ok, _account} = Accounting.delete_account(account)

    conn
    |> put_flash(:info, dgettext("accounts", "delete_success"))
    |> redirect(to: Routes.account_path(conn, :index))
  end
end
