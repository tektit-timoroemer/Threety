defmodule Fourty.AccountingTest do
  use Fourty.DataCase

  alias Fourty.Accounting

  describe "accounts" do
    alias Fourty.Accounting.Account

    @valid_attrs %{date_end: ~D[2010-04-17], date_start: ~D[2010-04-17], name: "some name"}
    @update_attrs %{date_end: ~D[2011-05-18], date_start: ~D[2011-05-18], name: "some updated name"}
    @invalid_attrs %{balance_cur: nil, balance_dur: nil, date_end: nil, date_start: nil, name: nil}

    defp same_accounts?(a1, a2) do
      # return true if both accounts are identical ignoring any
      # associations
      Map.equal?(Map.drop(a1, [:project]), Map.drop(a2, [:project]))
    end

    def project_id() do
      {:ok, client} = Fourty.Clients.create_client(%{name: "test-client"})
      {:ok, project} = Fourty.Clients.create_project(%{name: "test-project", client_id: client.id})
      project.id
    end

    def account_fixture(attrs \\ %{}) do 
      {:ok, account} =
        attrs
        |> Enum.into(Map.merge(@valid_attrs, %{project_id: project_id()}))
        |> Accounting.create_account()
      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      result = Accounting.list_accounts()
      [%Fourty.Clients.Client{visible_projects: [%Fourty.Clients.Project{visible_accounts: [db_account]}]}] = result
      assert same_accounts?(db_account, account)
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      result = Accounting.get_account!(account.id)
      assert same_accounts?(result, account)
    end

    test "create_account/1 with valid data creates an account" do
      assert {:ok, %Account{} = account} = Accounting.create_account(Map.merge(@valid_attrs, %{project_id: project_id()}))
      assert account.balance_cur == 0
      assert account.balance_dur == 0
      assert account.date_end == ~D[2010-04-17]
      assert account.date_start == ~D[2010-04-17]
      assert account.name == "some name"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Accounting.update_account(account, @update_attrs)
      assert account.balance_cur == 0
      assert account.balance_dur == 0
      assert account.date_end == ~D[2011-05-18]
      assert account.date_start == ~D[2011-05-18]
      assert account.name == "some updated name"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_account(account, @invalid_attrs)
      assert same_accounts?(account, Accounting.get_account!(account.id))
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounting.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounting.change_account(account)
    end
  end

  describe "deposits" do
    alias Fourty.Accounting.Deposit

    @valid_attrs %{amount_cur: 42, amount_dur: 43, description: "test deposits"}
    @update_attrs %{amount_cur: 44, amount_dur: 45, description: "updated deposit"}
    @invalid_attrs %{amount_cur: nil, amount_dur: nil, description: nil}

    def order_fixture(project_id) do
      {:ok, order} = Fourty.Clients.create_order(
        %{project_id: project_id, description: "test order"})
      order
    end

    def deposit_fixture(account_id \\ nil, order_id \\ nil, attrs \\ %{}) do
      account = if is_nil(account_id), 
        do: account_fixture(), 
        else: Fourty.Accounting.get_account!(account_id)
      refute is_nil(account)

      order_id =  order_id || order_fixture(account.project_id).id
      {:ok, deposit} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{account_id: account.id, order_id: order_id})
        |> Accounting.create_deposit()
      deposit
    end

    def same_deposit?(d1, d2) do
      Map.equal?(Map.drop(d1, [:account, :order]), Map.drop(d2, [:account, :order]))
    end

    test "list_deposits/account_id returns all deposits for given account" do
      deposit = deposit_fixture()
      assert Accounting.list_deposits(account_id: deposit.account_id) == [deposit]
    end

    test "list_deposits/order_id returns all deposits for given order" do
      deposit = deposit_fixture()
      assert Accounting.list_deposits(order_id: deposit.order_id) == [deposit]
    end

    test "get_deposit!/1 returns the deposit with given id" do
      deposit = deposit_fixture()
      assert same_deposit?(Accounting.get_deposit!(deposit.id), deposit)
    end

    test "create_deposit/1 with valid data creates a deposit" do
      account = account_fixture()
      order = order_fixture(account.project_id)
      deposit = %{}
      |> Enum.into(@valid_attrs)
      |> Enum.into(%{account_id: account.id, order_id: order.id})
      |> Accounting.create_deposit()
      assert {:ok, %Deposit{} = deposit} = deposit
      assert deposit.amount_cur == 42
      assert deposit.amount_dur == 43
      assert deposit.description == "test deposits"
    end

    test "create_deposit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_deposit(@invalid_attrs)
    end

    test "update_deposit/2 with valid data updates the deposit" do
      deposit = deposit_fixture()
      assert {:ok, %Deposit{} = deposit} = Accounting.update_deposit(deposit, @update_attrs)
      assert deposit.amount_cur == 44
      assert deposit.amount_dur == 45
    end

    test "update_deposit/2 with invalid data returns error changeset" do
      deposit = deposit_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_deposit(deposit, @invalid_attrs)
      assert same_deposit?(deposit, Accounting.get_deposit!(deposit.id))
    end

    test "delete_deposit/1 deletes the deposit" do
      deposit = deposit_fixture()
      assert {:ok, %Deposit{}} = Accounting.delete_deposit(deposit)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_deposit!(deposit.id) end
    end

    test "change_deposit/1 returns a deposit changeset" do
      deposit = deposit_fixture()
      assert %Ecto.Changeset{} = Accounting.change_deposit(deposit)
    end
  end

  describe "withdrwls" do
    alias Fourty.Accounting.Withdrwl

    @valid_attrs %{amount_cur: 42, amount_dur: 42, rate_cur_per_hour: "some rate_cur_per_hour"}
    @update_attrs %{amount_cur: 43, amount_dur: 43, rate_cur_per_hour: "some updated rate_cur_per_hour"}
    @invalid_attrs %{amount_cur: nil, amount_dur: nil, rate_cur_per_hour: nil}

    def withdrwl_fixture(attrs \\ %{}) do
      {:ok, withdrwl} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounting.create_withdrwl()

      withdrwl
    end

    test "list_withdrwls/0 returns all withdrwls" do
      withdrwl = withdrwl_fixture()
      assert Accounting.list_withdrwls() == [withdrwl]
    end

    test "get_withdrwl!/1 returns the withdrwl with given id" do
      withdrwl = withdrwl_fixture()
      assert Accounting.get_withdrwl!(withdrwl.id) == withdrwl
    end

    test "create_withdrwl/1 with valid data creates a withdrwl" do
      assert {:ok, %Withdrwl{} = withdrwl} = Accounting.create_withdrwl(@valid_attrs)
      assert withdrwl.amount_cur == 42
      assert withdrwl.amount_dur == 42
      assert withdrwl.rate_cur_per_hour == "some rate_cur_per_hour"
    end

    test "create_withdrwl/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_withdrwl(@invalid_attrs)
    end

    test "update_withdrwl/2 with valid data updates the withdrwl" do
      withdrwl = withdrwl_fixture()
      assert {:ok, %Withdrwl{} = withdrwl} = Accounting.update_withdrwl(withdrwl, @update_attrs)
      assert withdrwl.amount_cur == 43
      assert withdrwl.amount_dur == 43
      assert withdrwl.rate_cur_per_hour == "some updated rate_cur_per_hour"
    end

    test "update_withdrwl/2 with invalid data returns error changeset" do
      withdrwl = withdrwl_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_withdrwl(withdrwl, @invalid_attrs)
      assert withdrwl == Accounting.get_withdrwl!(withdrwl.id)
    end

    test "delete_withdrwl/1 deletes the withdrwl" do
      withdrwl = withdrwl_fixture()
      assert {:ok, %Withdrwl{}} = Accounting.delete_withdrwl(withdrwl)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_withdrwl!(withdrwl.id) end
    end

    test "change_withdrwl/1 returns a withdrwl changeset" do
      withdrwl = withdrwl_fixture()
      assert %Ecto.Changeset{} = Accounting.change_withdrwl(withdrwl)
    end
  end
end
