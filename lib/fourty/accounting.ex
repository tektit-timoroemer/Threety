defmodule Fourty.Accounting do
  @moduledoc """
  The Accounting context.
  """

  import Ecto.Query, warn: false
  alias Fourty.Repo

  alias Fourty.Accounting.Account

  @doc """
  Returns the list of accounts in the order of their names

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    q = from c in Fourty.Clients.Client,
      join: p in assoc(c, :visible_projects),
      join: a in assoc(p, :visible_accounts),
      order_by: [c.id, p.id, a.name],
      preload: [visible_projects: {p, visible_accounts: a}]
    Repo.all(q)
  end

  def list_all_accounts do
    qa = from a in Account, order_by: a.name
    qp = from p in Fourty.Clients.Project, order_by: p.id, preload: [visible_accounts: ^qa] 
    qc = from c in Fourty.Clients.Client, order_by: c.id, preload: [visible_projects: ^qp]
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
  def get_account!(id), do: Repo.get!(Account, id)

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
  def list_deposits do
    Repo.all(Deposit)
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
  def get_deposit!(id), do: Repo.get!(Deposit, id)

  @doc """
  Creates a deposit.

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
  Updates a deposit.

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

  alias Fourty.Accounting.Withdrwl

  @doc """
  Returns the list of withdrwls.

  ## Examples

      iex> list_withdrwls()
      [%Withdrwl{}, ...]

  """
  def list_withdrwls do
    Repo.all(Withdrwl)
  end

  @doc """
  Gets a single withdrwl.

  Raises `Ecto.NoResultsError` if the Withdrwl does not exist.

  ## Examples

      iex> get_withdrwl!(123)
      %Withdrwl{}

      iex> get_withdrwl!(456)
      ** (Ecto.NoResultsError)

  """
  def get_withdrwl!(id), do: Repo.get!(Withdrwl, id)

  @doc """
  Creates a withdrwl.

  ## Examples

      iex> create_withdrwl(%{field: value})
      {:ok, %Withdrwl{}}

      iex> create_withdrwl(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_withdrwl(attrs \\ %{}) do
    %Withdrwl{}
    |> Withdrwl.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a withdrwl.

  ## Examples

      iex> update_withdrwl(withdrwl, %{field: new_value})
      {:ok, %Withdrwl{}}

      iex> update_withdrwl(withdrwl, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_withdrwl(%Withdrwl{} = withdrwl, attrs) do
    withdrwl
    |> Withdrwl.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a withdrwl.

  ## Examples

      iex> delete_withdrwl(withdrwl)
      {:ok, %Withdrwl{}}

      iex> delete_withdrwl(withdrwl)
      {:error, %Ecto.Changeset{}}

  """
  def delete_withdrwl(%Withdrwl{} = withdrwl) do
    Repo.delete(withdrwl)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking withdrwl changes.

  ## Examples

      iex> change_withdrwl(withdrwl)
      %Ecto.Changeset{data: %Withdrwl{}}

  """
  def change_withdrwl(%Withdrwl{} = withdrwl, attrs \\ %{}) do
    Withdrwl.changeset(withdrwl, attrs)
  end
end
