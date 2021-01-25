defmodule Fourty.AccountingTest do
  use Fourty.DataCase

  alias Fourty.Accounting

  describe "accounts" do
    alias Fourty.Accounting.Account

    @valid_attrs %{balance: 42, date_end: ~D[2010-04-17], date_start: ~D[2010-04-17], name: "some name"}
    @update_attrs %{balance: 43, date_end: ~D[2011-05-18], date_start: ~D[2011-05-18], name: "some updated name"}
    @invalid_attrs %{balance: nil, date_end: nil, date_start: nil, name: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounting.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounting.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounting.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Accounting.create_account(@valid_attrs)
      assert account.balance == 42
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
      assert account.balance == 43
      assert account.date_end == ~D[2011-05-18]
      assert account.date_start == ~D[2011-05-18]
      assert account.name == "some updated name"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_account(account, @invalid_attrs)
      assert account == Accounting.get_account!(account.id)
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
end
