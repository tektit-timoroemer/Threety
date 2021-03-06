defmodule Fourty.CostsTest do
  use Fourty.DataCase

  alias Fourty.Costs

  describe "work_items" do
    alias Fourty.Costs.WorkItem

    @valid_attrs %{
      account_id: 42,
      comments: "some comments",
      date_as_of: ~D[2010-04-17],
      duration: 42,
      order: 42,
      time_from: ~T[14:00:00],
      time_to: ~T[14:00:00],
      user_id: 42,
      withdrwl_id: 42
    }
    @update_attrs %{
      account_id: 43,
      comments: "some updated comments",
      date_as_of: ~D[2011-05-18],
      duration: 43,
      order: 43,
      time_from: ~T[15:01:01],
      time_to: ~T[15:01:01],
      user_id: 43,
      withdrwl_id: 43
    }
    @invalid_attrs %{
      account_id: nil,
      comments: nil,
      date_as_of: nil,
      duration: nil,
      order: nil,
      time_from: nil,
      time_to: nil,
      user_id: nil,
      withdrwl_id: nil
    }

    def work_item_fixture(attrs \\ %{}) do
      {:ok, work_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Costs.create_work_item()

      work_item
    end

    test "list_work_items/0 returns all work_items" do
      work_item = work_item_fixture()
      assert Costs.list_work_items() == [work_item]
    end

    test "get_work_item!/1 returns the work_item with given id" do
      work_item = work_item_fixture()
      assert Costs.get_work_item!(work_item.id) == work_item
    end

    test "create_work_item/1 with valid data creates a work_item" do
      assert {:ok, %WorkItem{} = work_item} = Costs.create_work_item(@valid_attrs)
      assert work_item.account_id == 42
      assert work_item.comments == "some comments"
      assert work_item.date_as_of == ~D[2010-04-17]
      assert work_item.duration == 42
      assert work_item.order == 42
      assert work_item.time_from == ~T[14:00:00]
      assert work_item.time_to == ~T[14:00:00]
      assert work_item.user_id == 42
      assert work_item.withdrwl_id == 42
    end

    test "create_work_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Costs.create_work_item(@invalid_attrs)
    end

    test "update_work_item/2 with valid data updates the work_item" do
      work_item = work_item_fixture()
      assert {:ok, %WorkItem{} = work_item} = Costs.update_work_item(work_item, @update_attrs)
      assert work_item.account_id == 43
      assert work_item.comments == "some updated comments"
      assert work_item.date_as_of == ~D[2011-05-18]
      assert work_item.duration == 43
      assert work_item.order == 43
      assert work_item.time_from == ~T[15:01:01]
      assert work_item.time_to == ~T[15:01:01]
      assert work_item.user_id == 43
      assert work_item.withdrwl_id == 43
    end

    test "update_work_item/2 with invalid data returns error changeset" do
      work_item = work_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Costs.update_work_item(work_item, @invalid_attrs)
      assert work_item == Costs.get_work_item!(work_item.id)
    end

    test "delete_work_item/1 deletes the work_item" do
      work_item = work_item_fixture()
      assert {:ok, %WorkItem{}} = Costs.delete_work_item(work_item)
      assert_raise Ecto.NoResultsError, fn -> Costs.get_work_item!(work_item.id) end
    end

    test "change_work_item/1 returns a work_item changeset" do
      work_item = work_item_fixture()
      assert %Ecto.Changeset{} = Costs.change_work_item(work_item)
    end
  end
end
