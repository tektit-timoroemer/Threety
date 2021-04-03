defmodule Fourty.AccountingTest do
  use Fourty.DataCase

  import Fourty.Setup
  alias Fourty.Accounting

  @valid_attrs %{
    date_end: ~D[2010-04-17],
    date_start: ~D[2010-04-17],
    label: "some label"
    }
  @update_attrs %{
    date_end: ~D[2011-05-18],
    date_start: ~D[2011-05-18],
    label: "some updated label"
  }
  @invalid_attrs %{
    date_end: nil,
    date_start: nil,
    label: nil
  }

  describe "test account_open?" do
    test "both dates not set" do
      a = account_fixture(%{date_start: nil, date_end: nil})
      assert Accounting.account_open?(a, ~D[2020-12-31])
      assert Accounting.account_open?(a, ~D[2021-01-01])
      assert Accounting.account_open?(a, ~D[2021-01-31])
      assert Accounting.account_open?(a, ~D[2021-02-01])
    end
    test "date_start set" do
      a = account_fixture(%{date_start: ~D[2021-01-01], date_end: nil})
      refute Accounting.account_open?(a, ~D[2020-12-31])
      assert Accounting.account_open?(a, ~D[2021-01-01])
      assert Accounting.account_open?(a, ~D[2021-01-31])
      assert Accounting.account_open?(a, ~D[2021-02-01])
    end
    test "date_end set" do
      a = account_fixture(%{date_start: nil, date_end: ~D[2021-02-01]})
      assert Accounting.account_open?(a, ~D[2020-12-31])
      assert Accounting.account_open?(a, ~D[2021-01-01])
      assert Accounting.account_open?(a, ~D[2021-01-31])
      refute Accounting.account_open?(a, ~D[2021-02-01])
    end
    test "both dates set" do
      a = account_fixture(%{date_start: ~D[2021-01-01], date_end: ~D[2021-02-01]})
      refute Accounting.account_open?(a, ~D[2020-12-31])
      assert Accounting.account_open?(a, ~D[2021-01-01])
      assert Accounting.account_open?(a, ~D[2021-01-31])
      refute Accounting.account_open?(a, ~D[2021-02-01])
    end
    test "both dates set to same date" do
      a = account_fixture(%{date_start: ~D[2021-01-15], date_end: ~D[2021-01-15]})
      refute Accounting.account_open?(a, ~D[2020-12-31])
      refute Accounting.account_open?(a, ~D[2021-01-01])
      refute Accounting.account_open?(a, ~D[2021-01-15])
      refute Accounting.account_open?(a, ~D[2021-01-31])
      refute Accounting.account_open?(a, ~D[2021-02-01])
    end
  end

  describe "accounts" do
    alias Fourty.Accounting.Account

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      result = Accounting.list_accounts()

      [
        %Fourty.Clients.Client{
          visible_projects: [%Fourty.Clients.Project{visible_accounts: [db_account]}]
        }
      ] = result

      assert same_accounts?(db_account, account)
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      result = Accounting.get_account!(account.id)
      assert same_accounts?(result, account)
    end

    test "create_account/1 with valid data creates an account" do
      assert {:ok, %Account{} = account} =
        Accounting.create_account(
          Map.merge(@valid_attrs, %{project_id: project_fixture().id}))

      assert account.balance_cur == nil
      assert account.balance_dur == nil
      assert account.date_end == ~D[2010-04-17]
      assert account.date_start == ~D[2010-04-17]
      assert account.label == "some label"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Accounting.update_account(account, @update_attrs)
      assert account.balance_cur == nil
      assert account.balance_dur == nil
      assert account.date_end == ~D[2011-05-18]
      assert account.date_start == ~D[2011-05-18]
      assert account.label == "some updated label"
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

    @valid_attrs %{amount_cur: 42, amount_dur: 43, label: "test deposits"}
    @update_attrs %{amount_cur: 44, amount_dur: 45, label: "updated deposit"}
    @invalid_attrs %{amount_cur: nil, amount_dur: nil, label: nil}

    test "list_deposits/account_id returns all deposits for given account" do
      deposit = deposit_fixture()
      [d1] = Accounting.list_deposits(account_id: deposit.account_id)
      assert same_deposits?(d1, deposit)
    end

    test "list_deposits/order_id returns all deposits for given order" do
      order = order_fixture()
      deposit = deposit_fixture(%{order_id: order.id})
      [d1] = Accounting.list_deposits(order_id: deposit.order_id)
      assert same_deposits?(d1, deposit)
    end

    test "get_deposit!/1 returns the deposit with given id" do
      deposit = deposit_fixture()
      assert same_deposits?(Accounting.get_deposit!(deposit.id), deposit)
    end

    test "create_deposit/1 with valid data creates a deposit" do
      account = account_fixture()
      order = order_fixture(%{project_id: account.project_id})

      deposit =
        %{}
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{account_id: account.id, order_id: order.id})
        |> Accounting.create_deposit()

      assert {:ok, %Deposit{} = deposit} = deposit
      assert deposit.amount_cur == 42
      assert deposit.amount_dur == 43
      assert deposit.label == "test deposits"
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
      assert same_deposits?(deposit, Accounting.get_deposit!(deposit.id))
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

  describe "withdrawals" do
    alias Fourty.Accounting.Withdrawal

    @valid_attrs %{amount_cur: 42, amount_dur: 43, label: "test withdrawals"}
    @update_attrs %{amount_cur: 44, amount_dur: 45, label: "updated withdrawals"}
    @invalid_attrs %{amount_cur: nil, amount_dur: nil, label: nil}

    test "list_withdrawals/0 returns all withdrawals" do
      withdrawal = withdrawal_fixture()
      assert Accounting.list_withdrawals(account_id: withdrawal.account_id) == [withdrawal]
    end

    test "get_withdrawal!/1 returns the withdrawal with given id" do
      withdrawal = withdrawal_fixture()
      assert Accounting.get_withdrawal!(withdrawal.id) == withdrawal
    end

    test "create_withdrawal/1 with valid data creates a withdrawal" do
      a = account_fixture()
      attrs = Map.merge(@valid_attrs, %{account_id: a.id})
      assert {:ok, %Withdrawal{} = withdrawal} = Accounting.create_withdrawal(attrs)
      assert withdrawal.amount_cur == 42
      assert withdrawal.amount_dur == 43
    end

    test "create_withdrawal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_withdrawal(@invalid_attrs)
    end

    test "update_withdrawal/2 with valid data updates the withdrawal" do
      withdrawal = withdrawal_fixture()
      assert {:ok, %Withdrawal{} = withdrawal} = Accounting.update_withdrawal(withdrawal, @update_attrs)
      assert withdrawal.amount_cur == 44
      assert withdrawal.amount_dur == 45
    end

    test "update_withdrawal/2 with invalid data returns error changeset" do
      withdrawal = withdrawal_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_withdrawal(withdrawal, @invalid_attrs)
      assert withdrawal == Accounting.get_withdrawal!(withdrawal.id)
    end

    test "delete_withdrawal/1 deletes the withdrawal" do
      withdrawal = withdrawal_fixture()
      assert {:ok, %Withdrawal{}} = Accounting.delete_withdrawal(withdrawal)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_withdrawal!(withdrawal.id) end
    end

    test "change_withdrawal/1 returns a withdrawal changeset" do
      withdrawal = withdrawal_fixture()
      assert %Ecto.Changeset{} = Accounting.change_withdrawal(withdrawal)
    end
  end
end
