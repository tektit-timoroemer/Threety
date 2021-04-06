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
  alias Fourty.Accounting.Withdrawal

  @doc """
  Exchange the sequence number of the two items (utility to allow
  manual sorting of work_items). Must only be permitted for same user
  and for same date!
  """
  def flip_sequence(item1, item2) do
    Multi.new()
    |> Multi.run(:get_items, fn _repo, _changes ->
        get_items([item1, item2])
        end)
    |> Multi.run(:update_item1a, fn repo, %{get_items: %{item1a: cs}} ->
        repo.update(cs)
        end)
    |> Multi.run(:update_item2, fn repo, %{get_items: %{item2: cs}} ->
        repo.update(cs)
        end)
    |> Multi.run(:update_item1b, fn repo, %{get_items: %{item1b: cs}} ->
        repo.update(cs)
        end)
    |> Repo.transaction()
  end

  # retrieve and check 2 items, returns {:error, msg} or 
  # {:ok, [changeset for item1, changeset for item2]}

  defp get_items(item_list) when length(item_list) == 2 do
    q = from w in WorkItem, where: w.id in ^item_list
    items = Repo.all(q)
    if length(items) != 2 do
      {:error, "invalid_no_of_items"}
    else
      [item1, item2] = items
      cond do
      item1.date_as_of != item2.date_as_of ->
        {:error, "items_not_same_date"}
      item1.user_id != item2.user_id ->
        {:error, "items_not_same_user"}
      true ->
        # need to consider unique constraint for sequence numbers ...
        item1a_cs = Ecto.Changeset.change(item1, %{sequence: 0})
        item2_cs = Ecto.Changeset.change(item2, %{sequence: item1.sequence})
        item1b_cs = Ecto.Changeset.change(item1, %{sequence: item2.sequence})
        {:ok, %{item1a: item1a_cs, item2: item2_cs, item1b: item1b_cs}}
      end
    end   
  end

  @doc """
  Returns the list of work_items a the given user and date

  ## Examples

      iex> list_work_items()
      [%WorkItem{}, ...]

  """
  def list_work_items(user_id, date_as_of) do
    q = from w in WorkItem,
#      inner_join: a in assoc(w, :account),
      inner_join: wd in assoc(w, :withdrawal),
      inner_join: a in assoc(wd, :account),
      where: w.user_id == ^user_id and
        w.date_as_of == ^date_as_of,
      order_by: w.sequence,
#      preload: [account: a]
      preload: [withdrawal: {wd, [account: a]}]
    Repo.all(q)
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
    q = from w in WorkItem,
      inner_join: u in assoc(w, :user),
      inner_join: wd in assoc(w, :withdrawal),
#      inner_join: a in assoc(w, :account),
#      preload: [user: u, account: a, withdrawal: wd]
      inner_join: a in assoc(wd, :account),
      preload: [user: u, withdrawal: {wd, [account: a]}]
    Repo.get!(q, id)
    |> copy_account_id()
  end

  defp copy_account_id(%WorkItem{} = w) do
    Map.put(w, :account_id, w.withdrawal.account_id)
  end

  @doc """
  Creates a work_item and inserts it at the end of the given date
  (sequence will be set to max(sequence)+1)

  ## Examples

      iex> create_work_item(%{field: value})
      {:ok, %WorkItem{}}

      iex> create_work_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work_item(attrs \\ %{}) do
    work_item_cs = WorkItem.changeset(%WorkItem{}, attrs)
    # complete WorkItem record
    user_id = Changeset.get_field(work_item_cs, :user_id)
    account_id = Changeset.get_field(work_item_cs, :account_id)
    date_as_of = Changeset.get_field(work_item_cs, :date_as_of)
    duration = WorkItem.get_duration(work_item_cs)
    rate = Users.get_rate_for_user!(user_id)
    amount_cur = compute_cost(duration, rate)
    label = create_withdrawal_label(user_id, date_as_of, rate)
    max_sequence = get_max_sequence(user_id, date_as_of)
    withdrawal_cs = Withdrawal.changeset(%Withdrawal{}, %{
        amount_cur: amount_cur, amount_dur: duration,
        label: label, account_id: account_id})
    work_item_cs
    |> Changeset.put_change(:sequence, max_sequence + 1)
    |> Changeset.put_change(:duration, duration)
    |> Changeset.put_assoc(:withdrawal, withdrawal_cs)
    |> Repo.insert()
  end

  defp create_withdrawal_label(user_id, date_as_of, rate) do
    dgettext("work_items", "withdrawal_label",
      user_id: user_id, date_as_of: date_as_of, 
      rate: Fourty.TypeCurrency.int2cur(rate))
  end

  defp compute_cost(duration, rate) do
    if duration && rate do
      div((duration * rate), 60)
    else
      nil
    end
  end

  # determine the hightest sequence number used so far for this
  # user and date, default is 0

  defp get_max_sequence(user_id, date_as_of) do
    if user_id && date_as_of do
      from( w in WorkItem, 
        where: w.user_id == ^user_id and w.date_as_of == ^date_as_of)
      |> Repo.aggregate(:max, :sequence) || 0
    else
      0
    end
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
    duration = WorkItem.get_duration(work_item_cs)
    amount_cur = compute_cost(duration, rate)
    account_id = Changeset.get_field(work_item_cs, :account_id)
    label = create_withdrawal_label(user_id, date_as_of, rate)
    work_item_cs = 
      if work_item_cs.valid? do
        Changeset.put_change(work_item_cs, :duration, duration)
      else
        work_item_cs
      end
    withdrawal_cs = Withdrawal.changeset(work_item.withdrawal, %{
        amount_cur: amount_cur, amount_dur: duration,
        label: label, account_id: account_id})
    Multi.new()
    |> Multi.update(:work_item, work_item_cs)
    |> Multi.update(:withdrawal, withdrawal_cs)
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
    Multi.new()
    |> Multi.delete(:delete1, work_item.withdrawal)
    |> Multi.delete(:delete2, work_item)
    |> Repo.transaction()
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
