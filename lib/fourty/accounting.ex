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
end
