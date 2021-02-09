defmodule Fourty.Clients do
  @moduledoc """
  The Clients context.
  """

  import Ecto.Query, warn: false
  alias Fourty.Repo

  alias Fourty.Clients.Client

  @doc """
  Returns the list of clients.

  ## Examples

      iex> list_clients()
      [%Client{}, ...]

  """
  def list_clients do
    from(Client, order_by: :id)
    |> Repo.all()
  end

  @doc """
  Returns a list of clients suitable for dropdown lists

  ## Examples

    iex> get_clients()
    [%{key: 1, value: "client 1"}, %{key: 2, value: "Client #2"}]

  """
  def get_clients do
    q = from c in Client,
      order_by: c.id,
      select: %{key: c.id, value: c.name}
    Repo.all(q)
  end

  @doc """
  Gets a single client.

  Raises `Ecto.NoResultsError` if the Client does not exist.

  ## Examples

      iex> get_client!(123)
      %Client{}

      iex> get_client!(456)
      ** (Ecto.NoResultsError)

  """
  def get_client!(id), do: Repo.get!(Client, id)

  @doc """
  Creates a client.

  ## Examples

      iex> create_client(%{field: value})
      {:ok, %Client{}}

      iex> create_client(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_client(attrs \\ %{}) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a client.

  ## Examples

      iex> update_client(client, %{field: new_value})
      {:ok, %Client{}}

      iex> update_client(client, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes the given client.

  Raises `Ecto.StaleEntryError` if the Client does not exist.

  ## Examples

      iex> delete_client(client)
      {:ok, %Client{}}

      iex> delete_client(client)
      {:error, %Ecto.Changeset{}}

      iex> delete_client(client, %{id: 0})
      {:error, %Ecto.StaleEntryError}

  """
  def delete_client(%Client{} = client) do
    Repo.delete(client)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client changes.

  ## Examples

      iex> change_client(client)
      %Ecto.Changeset{data: %Client{}}

  """
  def change_client(%Client{} = client, attrs \\ %{}) do
    Client.changeset(client, attrs)
  end

  alias Fourty.Clients.Project

  @doc """
  Returns a list of clients or a single client with their resp. its
  associated, visible projects. This is the structure needed to display
  data in views (projects grouped by clients).

  ## Examples

      iex> list_all_projects()
      [%client{}, ...]

  """
  def list_projects(client_id \\ nil) do
    qp = from p in Project, order_by: p.id
    qc = from c in Client, preload: [visible_projects: ^qp]
    qc = if is_nil(client_id), 
      do: order_by(qc, [c], c.id),
      else: where(qc, [c], c.id == ^client_id)
    Repo.all(qc)
  end

  @doc """
  Returns the list of projects of the given client 
  suitable for dropdown lists

  ## Examples

    iex> get_projects(client_id)
    [%{key: 1, value: "project 1"}, %{key: 2, value: "project #2"}]

  """
  def get_projects(client_id) do
    q = from p in Project,
      order_by: p.id,
      select: %{key: p.id, value: p.name},
      where: [client_id: ^client_id]
    Repo.all(q)
  end

  @doc """
  Gets a single project with its associated client data

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id) do
    Repo.get!(Project, id)
    |> Repo.preload(:client)
  end

  @doc """
  Creates a project. Note that an existing client(_id) must be specified
  or the create_project function will fail with a dbms error.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{...}}

      iex> create_project(%Project{...}, %{field: bad_value})
      {:error, %Ecto.Changeset{...}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  alias Fourty.Clients.Order

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders(client_id \\ nil, project_id \\ nil ) do
    cc = if is_nil(client_id), do: true, else: dynamic([c], c.id == ^client_id)
    cp = if is_nil(project_id), do: true, else: dynamic([p], p.id == ^project_id)
    qo = from o in Order,
          order_by: o.date_eff
    qp = from p in Fourty.Clients.Project,
          where: ^cp,
          order_by: p.id, 
          preload: [orders: ^qo] 
    qc = from c in Fourty.Clients.Client,
          where: ^cc,
          order_by: c.id, 
          preload: [visible_projects: ^qp]
    IO.inspect(qc)
    Repo.all(qc)
  end

  def sums_per_order_query(orders \\ []) when is_list(orders) do
    wc = if Enum.empty?(orders), do: true, else: dynamic([o], o.order_id in ^orders)
    from d in Fourty.Accounting.Deposit,
      select: %{
        order_id: d.order_id,
        sum_cur: sum(d.amount_cur),
        sum_dur: sum(d.amount_dur)},
      where: ^wc,
      group_by: d.order_id
  end

  @doc """
  Load and return sum of all orders per account:
  [account_id: x, sum_cur: y, sum_dur: z]
  Use this in get_order_sums to retrieve values for any account.
  """
  def load_order_sums(order) do
    r = sums_per_order_query([order.id])
    |> Repo.all()
    if r == [] do
      %{order | sum_cur: 0, sum_dur: 0}
    else
      [r] = r
      %{order | sum_cur: r.sum_cur, sum_dur: r.sum_dur}
    end
  end

  @doc """
  Returns a keyword list with sums of amounts per order:
  [order_id: x, sum_cur: y, sum_dur: z]
  Use this in get_order_sums to retrieve order sums for any account.
  """
  def load_all_order_sums(orders \\ []) do
    Repo.all(sums_per_order_query(orders))
  end

  def get_order_sums(order_sums, order_id) do
    Enum.find(order_sums, fn x -> x.order_id == order_id end) || %{ sum_cur: nil, sum_dur: nil}
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id) do
    Repo.get!(Order, id)
    |> Repo.preload(project: [:client])
    |> load_order_sums()
  end
  
  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end
end
