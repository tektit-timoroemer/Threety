defmodule Fourty.Costs do
  @moduledoc """
  The Costs context.
  """

  import Ecto.Query, warn: false
  alias Fourty.Repo

  alias Fourty.Costs.WorkItem

  @doc """
  Returns the list of work_items.

  ## Examples

      iex> list_work_items()
      [%WorkItem{}, ...]

  """
  def list_work_items do
    Repo.all(WorkItem)
  end

  @doc """
  Gets a single work_item.

  Raises `Ecto.NoResultsError` if the Work item does not exist.

  ## Examples

      iex> get_work_item!(123)
      %WorkItem{}

      iex> get_work_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_work_item!(id), do: Repo.get!(WorkItem, id)

  @doc """
  Creates a work_item.

  ## Examples

      iex> create_work_item(%{field: value})
      {:ok, %WorkItem{}}

      iex> create_work_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work_item(attrs \\ %{}) do
    %WorkItem{}
    |> WorkItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a work_item.

  ## Examples

      iex> update_work_item(work_item, %{field: new_value})
      {:ok, %WorkItem{}}

      iex> update_work_item(work_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_item(%WorkItem{} = work_item, attrs) do
    work_item
    |> WorkItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a work_item.

  ## Examples

      iex> delete_work_item(work_item)
      {:ok, %WorkItem{}}

      iex> delete_work_item(work_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_work_item(%WorkItem{} = work_item) do
    Repo.delete(work_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work_item changes.

  ## Examples

      iex> change_work_item(work_item)
      %Ecto.Changeset{data: %WorkItem{}}

  """
  def change_work_item(%WorkItem{} = work_item, attrs \\ %{}) do
    WorkItem.changeset(work_item, attrs)
  end
end
