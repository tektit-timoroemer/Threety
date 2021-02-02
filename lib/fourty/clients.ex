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
end
