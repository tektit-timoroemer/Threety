defmodule FourtyWeb.WithdrawalController do
  use FourtyWeb, :controller

  alias Fourty.Accounting
  alias Fourty.Accounting.Withdrawal

  def index_account(conn, %{"account_id" => account_id}) do
    withdrawals = Accounting.list_withdrawals(account_id: account_id)
    account = Fourty.Accounting.get_account_solo!(account_id)
    heading = dgettext("withdrawals", "index_account", label: account.label)
    render(conn, "index.html", withdrawals: withdrawals, heading: heading)
  end

  def new(conn, params) do
    changeset = Ecto.Changeset.cast(%Withdrawal{}, params, [:wrktm_id])
    withdrawal = 
      Ecto.Changeset.apply_changes(changeset)
      |> Fourty.Repo.preload(wrktm: [:user])
    # create list of accounts to choose from
#    accounts = Accounting.get_accounts()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"withdrawal" => withdrawal_params}) do
    case Accounting.create_withdrawal(withdrawal_params) do
      {:ok, withdrawal} ->
        conn
        |> put_flash(:info, dgettext("withdrawals", "create success"))
        |> redirect(to: Routes.withdrawal_path(conn, :show, withdrawal))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    withdrawal = Accounting.get_withdrawal!(id)
    render(conn, "show.html", withdrawal: withdrawal)
  end

  def edit(conn, %{"id" => id}) do
    withdrawal = Accounting.get_withdrawal!(id)
    changeset = Accounting.change_withdrawal(withdrawal)
    render(conn, "edit.html", withdrawal: withdrawal, changeset: changeset)
  end

  def update(conn, %{"id" => id, "withdrawal" => withdrawal_params}) do
    withdrawal = Accounting.get_withdrawal!(id)

    case Accounting.update_withdrawal(withdrawal, withdrawal_params) do
      {:ok, withdrawal} ->
        conn
        |> put_flash(:info, dgettext("withdrawals", "update success"))
        |> redirect(to: Routes.withdrawal_path(conn, :show, withdrawal))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", withdrawal: withdrawal, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    withdrawal = Accounting.get_withdrawal!(id)
    {:ok, _withdrawal} = Accounting.delete_withdrawal(withdrawal)

    conn
    |> put_flash(:info, dgettext("withdrawals", "delete success"))
    |> redirect(to: Routes.withdrawal_path(conn, :index))
  end
end
