defmodule Fourty.Costs do
  @moduledoc """
  The Costs context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Fourty.Repo
  alias Ecto.Multi
  import FourtyWeb.Gettext, only: [dgettext: 3]

  alias Fourty.Costs.WorkItem
  alias Fourty.Users
  alias Fourty.Accounting.Withdrwl

  @doc """
  Returns the list of work_items a the given user and date

  ## Examples

      iex> list_work_items()
      [%WorkItem{}, ...]

  """
  def list_work_items(_user_id, _date_as_of) do
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
  def get_work_item!(id) do
    Repo.get!(WorkItem, id)
    |> Repo.preload([:user, withdrwl: [:account]])
  end

  @doc """
  Creates a work_item and inserts it at the end of the given date
  (sequence will be set to count+1)

  ## Examples

      iex> create_work_item(%{field: value})
      {:ok, %WorkItem{}}

      iex> create_work_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work_item(attrs \\ %{}) do
    work_item = WorkItem.changeset(%WorkItem{}, attrs)
    # complete WorkItem record
    user_id = Changeset.get_field(work_item, :user_id)
    account_id = Changeset.get_field(work_item, :account_id)
    date_as_of = Changeset.get_field(work_item, :date_as_of)
    duration = WorkItem.get_duration(work_item, 0)
    rate = Users.get_rate_for_user!(user_id)
    amount_cur = compute_cost(duration, rate)
    description = create_withdrwl_description(user_id, date_as_of, rate)
    count = get_max_sequence(user_id, date_as_of)
    work_item = 
       Changeset.put_change(work_item, :sequence, count + 1)
    |> Changeset.put_change(:duration, duration)
    Withdrwl.changeset(%Withdrwl{}, %{
        amount_cur: amount_cur, amount_dur: duration,
        description: description, account_id: account_id})
    |> Changeset.put_assoc(:work_item, work_item)
    |> Repo.insert()
  end

  defp get_withdrwl_for_work_item(id) do
    query = from w in Withdrwl, where: w.work_item_id == ^id
    Repo.all(query) 
  end

  defp create_withdrwl_description(user_id, date_as_of, rate) do
    dgettext("work_items", "withdrwl_description",
      user_id: user_id, date_as_of: date_as_of, 
      rate: Fourty.TypeCurrency.int2cur(rate))
  end

  defp compute_cost(duration, rate) do
    div((duration * rate), 60)
  end

  defp get_max_sequence(user_id, date_as_of) do
    query = from w in WorkItem,
      where: w.user_id == ^user_id and w.date_as_of == ^date_as_of
    Repo.aggregate(query, :count)
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
    work_item_cs = WorkItem.changeset(work_item, attrs)
    user_id = Changeset.get_field(work_item_cs, :user_id)
    date_as_of = Changeset.get_field(work_item_cs, :date_as_of)
    rate = Users.get_rate_for_user!(user_id)
    duration = WorkItem.get_duration(work_item_cs, 0)
    amount_cur = compute_cost(duration, rate)
    account_id = Changeset.get_field(work_item_cs, :account_id)
    description = create_withdrwl_description(user_id, date_as_of, rate)
    work_item_cs = 
      if work_item_cs.valid? do
        Changeset.put_change(work_item_cs, :duration, duration)
      else
        work_item_cs
      end
    withdrwl_cs = Withdrwl.changeset(work_item.withdrwl, %{
        amount_cur: amount_cur, amount_dur: duration,
        description: description, account_id: account_id})
    Ecto.Multi.new()
    |> Ecto.Multi.update(:work_item, work_item_cs)
    |> Ecto.Multi.update(:withdrwl, withdrwl_cs)
    |> Repo.transaction()
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
