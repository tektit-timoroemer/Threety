defmodule Fourty.CostsTest do
  use Fourty.DataCase

  import Fourty.Setup
  alias Fourty.{Costs, Users, Accounting}

  describe "work_items" do
    alias Fourty.Costs.WorkItem

    @valid_attrs %{
      label: "some label",
      time_from: "14:00",
      time_to: "14:01",
    }
    @update_attrs %{
      label: "some updated label",
      duration: 2,
      time_from: "15:00",
      time_to: "15:02",
    }
    @invalid_attrs %{
      label: nil,
      date_as_of: nil,
      duration: nil,
      time_from: nil,
      time_to: nil,
    }

    test "get_rate_for_user - for non-existing users" do
      assert Users.get_rate_for_user!(nil) == 0
      assert Users.get_rate_for_user!(0) == 0
    end

    test "create_work_item - without existing users" do
      {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item()
      assert !cs.valid?
      assert List.keyfind(cs.errors, :user_id, 0)
    end

    test "get_work_item!/1 returns the work_item with given id" do
      work_item = work_item_fixture()
      assert same_work_items_and_withdrawals?(Costs.get_work_item!(work_item.id), work_item)
    end

    test "list_work_items/2 returns work_items for given user and day" do
      work_item = work_item_fixture()
      [result] = Costs.list_work_items(work_item.user_id, work_item.date_as_of)
      assert same_work_items?(result, work_item)
    end

    test "create_work_item/1 with valid data creates a work_item" do
      a = account_fixture()
      u = user_fixture()
      attrs = Map.merge(@valid_attrs,
        %{user_id: u.id, account_id: a.id, date_as_of: a.date_start})
      assert {:ok, %WorkItem{} = work_item} = Costs.create_work_item(attrs)
      assert work_item.label == "some label"
      assert work_item.date_as_of == a.date_start
      assert work_item.duration == 1
      assert work_item.sequence == 1
      assert work_item.time_from == 14 * 60
      assert work_item.time_to == 14 * 60 + 1
      assert work_item.user_id == u.id
      assert work_item.withdrawal.amount_dur == 1
      assert work_item.withdrawal.amount_cur == 1
      assert work_item.withdrawal.account_id == a.id
    end

    test "validate_account - must be open for accounting" do
      a1 = account_fixture(%{date_start: nil, date_end: nil})
      a2 = account_fixture(%{date_start: ~D[2021-01-01], date_end: ~D[2021-01-01]})
      u = user_fixture()

      valid_attrs = Map.merge(@valid_attrs, %{user_id: u.id, date_as_of: ~D[2021-01-01]})
      attrs = Map.merge(valid_attrs, %{account_id: a1.id})
      assert {:ok, %WorkItem{} = _work_item} = Costs.create_work_item(attrs)

      attrs = Map.merge(valid_attrs, %{account_id: a2.id})
      assert {:error, %Ecto.Changeset{} = _cs} = Costs.create_work_item(attrs)
    end

    test "create_work_item/1 with invalid data returns error changeset" do
      a = account_fixture()
      u = user_fixture()

      valid_attrs = Map.merge(@valid_attrs, %{date_as_of: a.date_start})
      attrs = Map.merge(valid_attrs, %{user_id: nil, account_id: a.id})
      assert {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item(attrs)
      assert List.keyfind(cs.errors, :user_id, 0)

      attrs = Map.merge(valid_attrs, %{user_id: u.id, account_id: nil})
      assert {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item(attrs)
      assert List.keyfind(cs.errors, :account_id, 0)

      valid_attrs = Map.merge(valid_attrs, %{user_id: u.id, account_id: a.id})
      attrs = Map.merge(valid_attrs, %{duration: 2})
      assert {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item(attrs)
      assert List.keyfind(cs.errors, :duration, 0)

      attrs = Map.merge(valid_attrs, %{duration: 0})
      assert {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item(attrs)
      assert List.keyfind(cs.errors, :duration, 0)

      attrs = Map.merge(valid_attrs, %{duration: -1})
      assert {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item(attrs)
      assert List.keyfind(cs.errors, :duration, 0)

      attrs = Map.merge(valid_attrs, %{time_from: 1, time_to: 0})
      assert {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item(attrs)
      assert List.keyfind(cs.errors, :duration, 0)
      assert List.keyfind(cs.errors, :time_from, 0)
      assert List.keyfind(cs.errors, :time_to, 0)

      attrs = Map.merge(valid_attrs, %{time_from: "23:59", time_to: "24:01"})
      assert {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item(attrs)
      assert List.keyfind(cs.errors, :duration, 0)
      assert List.keyfind(cs.errors, :time_to, 0)

      attrs = Map.merge(valid_attrs, %{time_from: "24:00", time_to: "24:00", duration: 2})
      assert {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item(attrs)
      assert List.keyfind(cs.errors, :duration, 0)
    end

    test "update_work_item/2 with valid data updates the work_item" do
      a1 = account_fixture()
      a2 = account_fixture()
      u1 = user_fixture()
      u2 = user_fixture()

      attrs = Map.merge(@valid_attrs,
        %{user_id: u1.id, account_id: a1.id, date_as_of: a1.date_start})
      assert {:ok, %WorkItem{} = work_item} = Costs.create_work_item(attrs)
      withdrawal_id = work_item.withdrawal.id
 
      attrs = Map.merge(@update_attrs,
        %{user_id: u2.id, account_id: a2.id, date_as_of: a2.date_start})
      assert {:ok,
        %{work_item: %WorkItem{} = work_item, 
          withdrawal: %Accounting.Withdrawal{} = withdrawal}} = 
        Costs.update_work_item(work_item, attrs)
      assert work_item.account_id == a2.id
      assert work_item.label == "some updated label"
      assert work_item.date_as_of == a2.date_start
      assert work_item.duration == 2
      assert work_item.sequence == 1
      assert work_item.time_from == 15 * 60
      assert work_item.time_to == 15 * 60 + 2
      assert work_item.user_id == u2.id
      assert withdrawal.work_item_id == work_item.id
      assert withdrawal.id == withdrawal_id
    end

    test "update_work_item/2 with invalid data returns error changeset" do
      a = account_fixture()
      u = user_fixture()

      valid_attrs = @valid_attrs
      attrs = Map.merge(valid_attrs,
        %{user_id: u.id, account_id: a.id, date_as_of: a.date_start})
      assert {:ok, %WorkItem{} = work_item} = Costs.create_work_item(attrs)

      {:error, :work_item, %Ecto.Changeset{}, %{}} = 
        Costs.update_work_item(work_item, @invalid_attrs)
      assert same_work_items_and_withdrawals?(work_item, Costs.get_work_item!(work_item.id))
    end

    test "delete_work_item/1 deletes the work_item" do
      work_item = work_item_fixture()
      withdrawal_id = work_item.withdrawal.id

      {:ok, %{delete1: %Accounting.Withdrawal{}, delete2: %WorkItem{}}} = 
        Costs.delete_work_item(work_item)
      assert_raise Ecto.NoResultsError, fn -> Costs.get_work_item!(work_item.id) end
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_withdrawal!(withdrawal_id) end
    end

    test "change_work_item/1 returns a work_item changeset" do
      work_item = work_item_fixture()
      assert %Ecto.Changeset{} = Costs.change_work_item(work_item)
    end
  end
end
