defmodule Fourty.Accounting do
  @moduledoc """
  The Accounting context.
  """

  import Ecto.Query, warn: false
  alias Fourty.Repo

  alias Fourty.Accounting.{Account, Deposit, Withdrawal}

  # create query for retrieval of account aggregates

  defp balance_per_account_query(accounts) when is_list(accounts) do
    wc =
      if Enum.empty?(accounts),
        do: true,
        else: dynamic([a], a.account_id in ^accounts)

    dq =
      from d in Fourty.Accounting.Deposit,
        select: %{
          account_id: d.account_id,
          amount_cur: d.amount_cur,
          amount_dur: d.amount_dur
        },
        where: ^wc

    wq =
      from w in Fourty.Accounting.Withdrawal,
        select: %{
          account_id: w.account_id,
          amount_cur: w.amount_cur * -1,
          amount_dur: w.amount_dur * -1
        },
        where: ^wc

    uq = union_all(wq, ^dq)

    from u in subquery(uq),
      group_by: u.account_id,
      select: %{
        account_id: u.account_id,
        balance_cur: sum(u.amount_cur),
        balance_dur: sum(u.amount_dur)
      }
  end

  def load_balance(account) do
    r =
      balance_per_account_query([account.id])
      |> Repo.all()

    if r == [] do
      %{account | balance_cur: 0, balance_dur: 0}
    else
      [r] = r
      %{account | balance_cur: r.balance_cur, balance_dur: r.balance_dur}
    end
  end

  @doc """
  Returns a keyword list with balances per account:
  [account_id: x, balance_cur: y, balance_dur: z]
  Use this in get_balance to retrieve balance values for any account.
  """
  def load_all_balances(accounts \\ []) do
    Repo.all(balance_per_account_query(accounts))
  end

  def get_balance(balances, account_id) do
    Enum.find(balances, fn x -> x.account_id == account_id end) ||
      %{balance_cur: 0, balance_dur: 0}
  end

  @doc """
  Returns the list of accounts in the order of their labels

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """

  # this will generate only a single query!
  # BUT it will list only those clients and projects with accounts...

  def alt_list_accounts(client_id \\ nil, project_id \\ nil) do
    cc = if client_id == nil, do: true, else: dynamic([c], c.id == ^client_id)
    cp = if project_id == nil, do: true, else: dynamic([c, p], p.id == ^project_id)

    q =
      from c in Fourty.Clients.Client,
        where: ^cc,
        join: p in assoc(c, :visible_projects),
        where: ^cp,
        join: a in assoc(p, :visible_accounts),
        order_by: [c.id, p.id, a.label],
        preload: [visible_projects: {p, visible_accounts: a}],
        select: a.id

    Repo.all(q)
  end

  # the following will generate 3 queries
  # listing all clients and projects whether they have accounts or not

  def list_accounts(client_id \\ nil, project_id \\ nil) do
    cc = if is_nil(client_id), do: true, else: dynamic([c], c.id == ^client_id)
    cp = if is_nil(project_id), do: true, else: dynamic([p], p.id == ^project_id)

    qa =
      from a in Account,
        order_by: a.label

    qp =
      from p in Fourty.Clients.Project,
        where: ^cp,
        order_by: p.id,
        preload: [visible_accounts: ^qa]

    qc =
      from c in Fourty.Clients.Client,
        where: ^cc,
        order_by: c.id,
        preload: [visible_projects: ^qp]

    Repo.all(qc)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account_solo!(id) do
    Repo.get!(Account, id)
  end

  def get_account!(id) do
    get_account_solo!(id)
    |> Repo.preload(project: [:client])
    |> load_balance()
  end

  @doc """
  Returns the list of accounts of the given project
  suitable for dropdown lists

  ## Examples

    iex> get_accounts(project_id)
    [%{key: 1, value: "account 1"}, %{key: 2, value: "account #2"}]
  """
  def get_accounts_for_project(project_id) do
    q =
      from a in Account,
        select: [key: a.label, value: a.id],
        where: [project_id: ^project_id, visible: true],
        order_by: a.id
    Repo.all(q)
  end

  @doc """
  Returns the list of accounts the user has access to;
  suitable for dropdown lists. Note: The specification for a user_id
  is a future feature when access/usage of accounts may be restricted.

  ## Examples

    iex> get_accounts_for_user(user_id)
    [%{key: 1, value: "account 1"}, %{key: 2, value: "account #2"}]
  """
  def get_accounts_for_user(_user_id) do
    q =
      from a in Account,
        select: [key: a.label, value: a.id],
        where: [visible: true],
        order_by: a.id
    Repo.all(q)
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  alias Fourty.Accounting.Deposit

  @doc """
  Returns the list of deposits.

  ## Examples

      iex> list_deposits()
      [%Deposit{}, ...]

  """
  def list_deposits(account_id: account_id) do
    q = from d in Deposit, where: d.account_id == ^account_id
    do_list_deposits(q)
  end

  def list_deposits(order_id: order_id) do
    q = from d in Deposit, where: d.order_id == ^order_id
    do_list_deposits(q)
  end

  defp do_list_deposits(query) do
    q = from d in query, order_by: d.inserted_at
    Repo.all(q)
    |> Repo.preload(:account)
  end

  @doc """
  Gets a single deposit.

  Raises `Ecto.NoResultsError` if the Deposit does not exist.

  ## Examples

      iex> get_deposit!(123)
      %Deposit{}

      iex> get_deposit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_deposit!(id) do
    Repo.get!(Deposit, id)
    |> Repo.preload([:account, :order])
  end

  @doc """
  Creates a deposit. This method does NOT check if the account is
  open or closed or visible!

  ## Examples

      iex> create_deposit(%{field: value})
      {:ok, %Deposit{}}

      iex> create_deposit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_deposit(attrs \\ %{}) do
    %Deposit{}
    |> Deposit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a deposit. This method does NOT check if the account is
  open or closed or visible!

  ## Examples

      iex> update_deposit(deposit, %{field: new_value})
      {:ok, %Deposit{}}

      iex> update_deposit(deposit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_deposit(%Deposit{} = deposit, attrs) do
    deposit
    |> Deposit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a deposit.

  ## Examples

      iex> delete_deposit(deposit)
      {:ok, %Deposit{}}

      iex> delete_deposit(deposit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_deposit(%Deposit{} = deposit) do
    Repo.delete(deposit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking deposit changes.

  ## Examples

      iex> change_deposit(deposit)
      %Ecto.Changeset{data: %Deposit{}}

  """
  def change_deposit(%Deposit{} = deposit, attrs \\ %{}) do
    Deposit.changeset(deposit, attrs)
  end

  alias Fourty.Accounting.Withdrawal

  @doc """
  Returns the list of withdrawals.

  ## Examples

      iex> list_withdrawals()
      [%Withdrawal{}, ...]

  """
  def list_withdrawals(account_id: account_id) do
    q = from d in Withdrawal, where: d.account_id == ^account_id
    do_list_withdrawals(q)
  end

  def list_withdrawals(task_id: task_id) do
    q = from d in Withdrawal, where: d.task_id == ^task_id
    do_list_withdrawals(q)
  end

  defp do_list_withdrawals(query) do
    q = from d in query, order_by: d.inserted_at
    Repo.all(q)
  end

  @doc """
  Gets a single withdrawal.

  Raises `Ecto.NoResultsError` if the Withdrawal does not exist.

  ## Examples

      iex> get_withdrawal!(123)
      %Withdrawal{}

      iex> get_withdrawal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_withdrawal!(id), do: Repo.get!(Withdrawal, id)

  @doc """
  Creates a withdrawal.

  ## Examples

      iex> create_withdrawal(%{field: value})
      {:ok, %Withdrawal{}}

      iex> create_withdrawal(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_withdrawal(attrs \\ %{}) do
    %Withdrawal{}
    |> Withdrawal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a withdrawal.

  ## Examples

      iex> update_withdrawal(withdrawal, %{field: new_value})
      {:ok, %Withdrawal{}}

      iex> update_withdrawal(withdrawal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_withdrawal(%Withdrawal{} = withdrawal, attrs) do
    withdrawal
    |> Withdrawal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a withdrawal.

  ## Examples

      iex> delete_withdrawal(withdrawal)
      {:ok, %Withdrawal{}}

      iex> delete_withdrawal(withdrawal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_withdrawal(%Withdrawal{} = withdrawal) do
    Repo.delete(withdrawal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking withdrawal changes.

  ## Examples

      iex> change_withdrawal(withdrawal)
      %Ecto.Changeset{data: %Withdrawal{}}

  """
  def change_withdrawal(%Withdrawal{} = withdrawal, attrs \\ %{}) do
    Withdrawal.changeset(withdrawal, attrs)
  end
end
