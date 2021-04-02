defmodule Fourty.Setup do
#
# This module makes various data available in the test modules. I
# created it so I did not have to include such code into almost
# every test module...
#
	alias Fourty.{Clients, Accounting, Costs, Users}

  @client_label_prefix "client"
  @project_label_prefix "project"
  @account_label_prefix "account"
  @order_label "label for order"
  @work_item_date ~D[2021-01-01]
  @work_item_duration 10
  @user_username_prefix "user_"
  @user_email_suffix ".test@test.test"
  @user_rate 100

  # same_...? returns true if both items are identical except any
  # associations and virtual fields

  def same_clients?(c1, c2) do
  	Map.equal?(c1, c2)
  end

  def same_projects?(p1, p2) do
  	Map.equal?(
  		Map.drop(p1, [:client]),
  		Map.drop(p2, [:client])
  		)
  end

  def same_orders?(o1, o2) do
    Map.equal?(
      Map.drop(o1, [:deposits]),
      Map.drop(o2, [:deposits])
      )
  end
 
  def same_accounts?(a1, a2) do
    Map.equal?(
      Map.drop(a1, [:project, :balance_dur, :balance_cur]),
      Map.drop(a2, [:project, :balance_dur, :balance_cur])
      )
  end

  def same_deposits?(d1, d2) do
    Map.equal?(
      Map.drop(d1, [:account, :order]),
      Map.drop(d2, [:account, :order])
      )
  end

  def same_users?(u1, u2) do
    Map.equal?(u1, u2)
  end

  def same_withdrawals?(w1, w2) do
    Map.equal?(
      Map.drop(w1, [:account, :work_item]),
      Map.drop(w2, [:account, :work_item])
      )
  end

  def same_work_items?(wi1, wi2) do
    # return true if both work_items are identical ignoring
    # all associations, including withdrawal records
    Map.equal?(
      Map.drop(wi1, [:user, :withdrawal, :account_id]),
      Map.drop(wi2, [:user, :withdrawal, :account_id]))
  end

  def same_work_items_and_withdrawals?(wi1, wi2) do
    # return true if both work_items are identical ignoring any
    # associations other than withdrawal (which may or may not be loaded)
    same_withdrawals?(wi1.withdrawal, wi2.withdrawal)
      && same_work_items?(wi1, wi2)
  end

  # provide unique fixtures with minimal attributes

  def client_fixture(attrs \\ %{}) do
    unique_suffix = " (#{Fourty.Repo.aggregate(Clients.Client, :count)})"
    merged_attrs = Map.put_new(attrs, :label, @client_label_prefix <> unique_suffix)
		{:ok, client} = Clients.create_client(merged_attrs)
    client
  end

  def project_fixture(attrs \\ %{}) do
    unique_suffix = " (#{Fourty.Repo.aggregate(Clients.Project, :count)})"
    merged_attrs =
      Map.put_new(attrs, :label, @project_label_prefix <> unique_suffix)
      |> Map.put_new(:client_id, client_fixture().id)
    {:ok, project} = Clients.create_project(merged_attrs)
    project
  end

  def order_fixture(attrs \\ %{}) do
    merged_attrs = 
      Map.put_new(attrs, :label, @order_label)
      |> Map.put_new(:project_id, project_fixture().id)
    {:ok, order} = Clients.create_order(merged_attrs)
    order
  end

  def account_fixture(attrs \\ %{}) do
    unique_suffix = " (#{Fourty.Repo.aggregate(Accounting.Account, :count)})"
    merged_attrs = 
      Map.put_new(attrs, :label, @account_label_prefix <> unique_suffix)
      |> Map.put_new(:project_id, project_fixture().id)
    {:ok, account} = Accounting.create_account(merged_attrs)
    account
  end

  def user_fixture(attrs \\ %{}) do
    username = @user_username_prefix <>
      to_string(Fourty.Repo.aggregate(Users.User, :count))
    email = username <> @user_email_suffix
    merged_attrs =
      Map.merge(attrs,
        %{username: username, email: email, rate: @user_rate})
    {:ok, user} = Users.create_user(merged_attrs)
    user
  end

  def work_item_fixture(attrs \\ %{}) do
    merged_attrs = 
      Map.merge(attrs,
        %{duration: @work_item_duration,
          date_as_of: @work_item_date})
      |> Map.put_new(:account_id, 
          account_fixture(%{date_start: @work_item_date}).id)
      |> Map.put_new(:user_id, user_fixture().id)
    {:ok, work_item} = Costs.create_work_item(merged_attrs)
    work_item
  end

  def deposit_fixture(attrs \\ %{}) do
    merged_attrs =
      Map.merge(attrs, %{amount_cur: 100})
      |> Map.put_new(:account_id, account_fixture().id)
    {:ok, deposit} = Accounting.create_deposit(merged_attrs)
    deposit
  end

  def withdrawal_fixture(attrs \\ %{}) do
    merged_attrs =
      Map.merge(attrs, %{amount_cur: 100})
      |> Map.put_new(:account_id, account_fixture().id)
    {:ok, withdrawal} = Accounting.create_withdrawal(merged_attrs)
    withdrawal
  end 
end