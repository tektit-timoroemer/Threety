defmodule FourtyWeb.DepositController do
  use FourtyWeb, :controller

  alias Fourty.Accounting
  alias Fourty.Accounting.Deposit

  def index(conn, _params) do
    deposits = Accounting.list_deposits()
    render(conn, "index.html", deposits: deposits)
  end

  def new(conn, params) do
    # >>>>> if order already has link to deposit, set error message
    # >>>>> and return to show order
    changeset = Ecto.Changeset.cast(%Deposit{}, params, [:order_id])
    deposit = Ecto.Changeset.apply_changes(changeset)
    |> Fourty.Repo.preload(order: [project: [:client]])
    # >>>>> preset description, amounts from order
    accounts = Accounting.get_accounts(deposit.order.project.id)
    render(conn, "new.html", changeset: changeset, deposit: deposit,
      accounts: accounts)
  end

  def create(conn, %{"deposit" => deposit_params}) do
    IO.inspect(deposit_params)
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
