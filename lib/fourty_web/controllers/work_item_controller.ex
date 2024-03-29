defmodule FourtyWeb.WorkItemController do
  use FourtyWeb, :controller

  alias Fourty.Costs
  alias Fourty.Accounting
  alias Fourty.Costs.WorkItem
  alias FourtyWeb.ViewHelpers

  defp get_user(conn, user_id) do
    if user_id == "0" do
      get_session(conn, :current_user)
    else
      Fourty.Users.get_user!(user_id)
    end
  end

  defp get_date_as_of(params) do
    date_as_of = Map.get(params, "date_as_of", "today")
    case date_as_of do
      "today" ->
        Date.utc_today
      _ ->
        Date.from_iso8601!(date_as_of)
    end
  end

  # exchanges sequence number of the given items

  def flip(conn, %{"item1" => item1, "item2" => item2} = params) do
    {adm_only, _assigns} = Map.pop(conn.assigns, :adm_only, false)
    user_id = Map.get(params, "user_id", "0")
    date_as_of = get_date_as_of(params)
    conn = case Costs.flip_sequence(item1, item2) do
      {:error, last_step, _failure_info, %{}} ->
        put_flash(conn, :info, dgettext("work_items", "flip_failed", details: last_step))
      {:ok, _} -> conn
      end
    redirect(conn, to: if adm_only do
        Routes.work_item_user_path(conn, :index_date, user_id, to_string(date_as_of))
      else
        Routes.work_item_path(conn, :index_date, to_string(date_as_of))
      end)
  end

  # display all work_items for the given account

  def index_account(conn, params) do
  #  conn
  #  |> put_flash(:info, "not yet implemented")
  #  |> redirect(to: Routes.session_path(conn, :index))
    account_id = Map.get(params, "account_id", 0)
    account = Accounting.get_account_solo!(account_id)
    work_items = Costs.list_work_items(account_id: account_id)
    # format list of work items such that repetitive dates are listed
    # only once (secondary occurances are replaced by a blank value)
    |> Stream.transform("", fn wi, pd ->
          if pd == wi.date_as_of,
            do: {[Map.replace(wi, :date_as_of, "")], pd},
          else: {[wi], wi.date_as_of} end)
    |> Enum.to_list()
    render(conn, "index_account.html",
      work_items: work_items, account: account)
  end

  # index_date:
  # date defaults to today
  # user defaults to current user
  # cannot go into future beyond today

  def index_date(conn, params) do

    # determine for which date to report

    date_as_of = get_date_as_of(params)
    today = Date.utc_today
    {conn, date_as_of} = if Date.compare(date_as_of, today) == :gt do
      {put_flash(conn, :info, dgettext("work_items", "date_reset_to_today")), today}
    else
      {conn, date_as_of}
    end

    # have date, now prepare a nice label for the heading

    {msgid_suffix, date_label} = if (date_as_of == today) do
      {"today", ""}
    else
      {"date", ViewHelpers.date_with_weekday(date_as_of)}
    end

    # need ot determine the user for which to display the work items:
    # if no user_id was given, assume and determine the current user;
    # also prepare a name for the heading

    user_id = Map.get(params, "user_id", "0")
    {user, msgid} = 
      if user_id == "0" do
        {get_session(conn, :current_user), "my_index_"}
      else
        {Fourty.Users.get_user!(user_id), "others_index_"}
      end

    heading = Gettext.dgettext(FourtyWeb.Gettext, "work_items", 
      msgid <> msgid_suffix, name: user.username, date: date_label)
    work_items = Costs.list_work_items(user.id, date_as_of)
    render(conn, "index_date.html",
      work_items: work_items, heading: heading, date_as_of: date_as_of,
      user_id: user.id, adm_only: Map.get(conn.assigns, :adm_only, false))
  end

  def new(conn, params) do

    # need to extract adm_only because it is an atom not a string

    {adm_only, assigns} = Map.pop(conn.assigns, :adm_only, false)
    params = Map.merge(params, assigns)

    # user_id is the id for the user to create a work item for;
    # it is "0" if it is for the current user

    user_id = Map.get(params, "user_id", "0")
    date_as_of = Map.get(params, "date_as_of")
    user = get_user(conn, user_id)
    params = Map.put(params, "user_id", user.id)
    changeset = Costs.change_work_item(%WorkItem{}, params)
    accounts = Accounting.get_accounts_for_user(user.id)
    if length(accounts) == 0 do
      conn
      |> put_flash(:error, dgettext("work_items", "no_valid_accounts"))
      |> redirect(to: if adm_only do
          Routes.work_item_user_path(conn, :index_date, user_id, to_string(date_as_of))
        else
          Routes.work_item_path(conn, :index_date, to_string(date_as_of))
        end)
    else
      render(conn, "new.html", changeset: changeset, accounts: accounts,
        adm_only: adm_only, user_id: user_id, date_as_of: date_as_of, 
        username: user.username)
    end
  end

  def create(conn, %{"work_item" => work_item_params}) do
    {adm_only, _assigns} = Map.pop(conn.assigns, :adm_only, false)
    case Costs.create_work_item(work_item_params) do
      {:ok, work_item} ->
        conn
        |> put_flash(:info, dgettext("work_items", "create_success"))
        |> redirect(to: if adm_only do
            Routes.work_item_user_path(conn, :show, work_item.user_id, work_item.id)
           else
            Routes.work_item_path(conn, :show, work_item.id)
           end)
      {:error, %Ecto.Changeset{} = changeset} ->
        user_id = Ecto.Changeset.get_field(changeset, :user_id)
        user = get_user(conn, user_id)
        date_as_of = Ecto.Changeset.get_field(changeset, :date_as_of)
        accounts = Accounting.get_accounts_for_user(user.id)
        render(conn, "new.html", changeset: changeset, accounts: accounts,
          adm_only: adm_only, user_id: user_id,
          date_as_of: to_string(date_as_of), username: user.username)
    end
  end

  def show(conn, %{"id" => id}) do
    work_item = Costs.get_work_item!(id)
    render(conn, "show.html", work_item: work_item)
  end

  def edit(conn, %{"id" => id}) do
    {adm_only, _assigns} = Map.pop(conn.assigns, :adm_only, false)
    work_item = Costs.get_work_item!(id)
    changeset = Costs.change_work_item(work_item)
    accounts = Accounting.get_accounts_for_user(work_item.user_id)
    render(conn, "edit.html", work_item: work_item, 
      changeset: changeset, accounts: accounts, adm_only: adm_only,
      date_as_of: work_item.date_as_of, username: work_item.user.username)
  end

  def update(conn, %{"id" => id, "work_item" => work_item_params}) do
    {adm_only, _assigns} = Map.pop(conn.assigns, :adm_only, false)
    work_item = Costs.get_work_item!(id)
    case Costs.update_work_item(work_item, work_item_params) do
      {:ok, %{work_item: work_item, withdrawal: _withdrawal}} ->
        redirect_path = if adm_only do
          Routes.work_item_user_path(conn, :show, work_item.user_id, work_item)
        else
          Routes.work_item_path(conn, :show, work_item)
        end
        conn
        |> put_flash(:info, dgettext("work_items", "update_success"))
        |> redirect(to: redirect_path)
      {:error, :work_item, %Ecto.Changeset{} = changeset, %{}} ->
        accounts = Accounting.get_accounts_for_user(work_item.user_id)
        render(conn, "edit.html", work_item: work_item,
          changeset: changeset, accounts: accounts, adm_only: adm_only,
          date_as_of: work_item.date_as_of, username: work_item.user.username)
    end
  end

  def delete(conn, %{"id" => id}) do
    {adm_only, _assigns} = Map.pop(conn.assigns, :adm_only, false)
    work_item = Costs.get_work_item!(id)
    {:ok, _work_item} = Costs.delete_work_item(work_item)
    conn
    |> put_flash(:info, dgettext("work_items", "delete_success"))
    |> redirect(to: if adm_only do
          Routes.work_item_user_path(conn, :index_date, work_item.user_id, to_string(work_item.date_as_of))
        else
          Routes.work_item_path(conn, :index_date, to_string(work_item.date_as_of))
        end)
  end
end
