defmodule Fourty.CostsTest do
  use Fourty.DataCase

  alias Fourty.Costs
  alias Fourty.Users
  alias Fourty.Clients
  alias Fourty.Accounting

  describe "work_items" do
    alias Fourty.Costs.WorkItem

    @valid_attrs %{
      comments: "some comments",
      date_as_of: ~D[2021-03-25],
      time_from: "14:00",
      time_to: "14:01",
    }
    @update_attrs %{
      comments: "some updated comments",
      date_as_of: ~D[2021-03-26],
      duration: 2,
      time_from: "15:00",
      time_to: "15:02",
    }
    @invalid_attrs %{
      comments: nil,
      date_as_of: nil,
      duration: nil,
      time_from: nil,
      time_to: nil,
    }

    @min_user_attrs %{
      username: "me",
      email: "me@test.test",
      rate: 100
    }

    @min_account_attrs %{name: "name of account"} # project_id: project_fixture()
    @min_project_attrs %{name: "name of project"} # client_id: client_fixture()
    @min_client_attrs %{name: "name of client"}

    def client_fixture(attrs \\ %{}) do
      {:ok, client} =
        Map.merge(@min_client_attrs, attrs)
        |> Clients.create_client()
      client
    end

    def project_fixture(attrs \\ %{client_id: client_fixture().id}) do
      {:ok, project} =
        Map.merge(@min_project_attrs, attrs)
        |> Clients.create_project()
      project
    end

    def user_fixture(attrs \\ %{}) do
      {:ok, user} = 
        Map.merge(@min_user_attrs, attrs)
        |> Users.create_user()
      user
    end

    def account_fixture(attrs \\ %{project_id: project_fixture().id}) do
      {:ok, account} = 
        Map.merge(@min_account_attrs, attrs)
        |> Accounting.create_account()
      account
    end

    def work_item_fixture(attrs \\ %{user_id: user_fixture().id, account_id: account_fixture().id}) do
      {:ok, work_item} =
        Map.merge(@valid_attrs, attrs)
        |> Costs.create_work_item()
      work_item
    end

    def same_work_items_1?(wi1, wi2) do
      # return true if both work_items are identical ignoring
      # all associations, including withdrwl records
      Map.equal?(
        Map.drop(wi1, [:user, :withdrwl, :account_id]),
        Map.drop(wi2, [:user, :withdrwl, :account_id]))
    end

    def same_work_items_2?(wi1, wi2) do
      # return true if both work_items are identical ignoring any
      # associations other than withdrwl (which may or may not be loaded)
      Map.equal?(
        Map.drop(wi1.withdrwl, [:account, :work_item]),
        Map.drop(wi2.withdrwl, [:account, :work_item]))
      &&
      same_work_items_1?(wi1, wi2)
    end

    test "validate support fixtures creation" do
      c = client_fixture()
      assert %Fourty.Clients.Client{name: "name of client"} = c
      p = project_fixture(%{client_id: c.id})
      assert %Fourty.Clients.Project{name: "name of project"} = p
      assert p.client_id == c.id
      a = account_fixture(%{project_id: p.id})
      assert %Fourty.Accounting.Account{name: "name of account"} = a 
      assert a.project_id == p.id
      u = user_fixture()
      assert u.username == "me"
    end

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
      assert same_work_items_2?(Costs.get_work_item!(work_item.id), work_item)
    end

    test "list_work_items/2 returns work_items for given user and day" do
      work_item = work_item_fixture()
      [result] = Costs.list_work_items(work_item.user_id, work_item.date_as_of)
      assert same_work_items_1?(result, work_item)
    end

    test "create_work_item/1 with valid data creates a work_item" do
      a = account_fixture()
      u = user_fixture()
      attrs = Map.merge(@valid_attrs, %{user_id: u.id, account_id: a.id})
      assert {:ok, %WorkItem{} = work_item} = Costs.create_work_item(attrs)
      assert work_item.comments == "some comments"
      assert work_item.date_as_of == ~D[2021-03-25]
      assert work_item.duration == 1
      assert work_item.sequence == 1
      assert work_item.time_from == 14 * 60
      assert work_item.time_to == 14 * 60 + 1
      assert work_item.user_id == u.id
      assert work_item.withdrwl.amount_dur == 1
      assert work_item.withdrwl.amount_cur == 1
      assert work_item.withdrwl.account_id == a.id
    end

    test "create_work_item/1 with invalid data returns error changeset" do
      a = account_fixture()
      u = user_fixture()

      valid_attrs = @valid_attrs
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

      attrs = Map.merge(valid_attrs, %{time_from: 0, time_to: 0})
      assert {:error, %Ecto.Changeset{} = cs} = Costs.create_work_item(attrs)
      assert List.keyfind(cs.errors, :duration, 0)
      assert List.keyfind(cs.errors, :time_from, 0)
      assert List.keyfind(cs.errors, :time_to, 0)

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
      assert List.keyfind(cs.errors, :time_from, 0)
      assert List.keyfind(cs.errors, :time_to, 0)
    end

    test "update_work_item/2 with valid data updates the work_item" do
      a1 = account_fixture()
      a2 = account_fixture(%{name: "another name", project_id: a1.project_id})
      u1 = user_fixture()
      u2 = user_fixture(%{username: "another one", email: "anne.other@test.test"})

      attrs = Map.merge(@valid_attrs, %{user_id: u1.id, account_id: a1.id})
      assert {:ok, %WorkItem{} = work_item} = Costs.create_work_item(attrs)
      withdrwl_id = work_item.withdrwl.id
 
      attrs = Map.merge(@update_attrs, %{user_id: u2.id, account_id: a2.id})
      assert {:ok,
        %{work_item: %WorkItem{} = work_item, 
          withdrwl: %Accounting.Withdrwl{} = withdrwl}} = 
        Costs.update_work_item(work_item, attrs)
      assert work_item.account_id == a2.id
      assert work_item.comments == "some updated comments"
      assert work_item.date_as_of == ~D[2021-03-26]
      assert work_item.duration == 2
      assert work_item.sequence == 1
      assert work_item.time_from == 15 * 60
      assert work_item.time_to == 15 * 60 + 2
      assert work_item.user_id == u2.id
      assert withdrwl.work_item_id == work_item.id
      assert withdrwl.id == withdrwl_id
    end

    test "update_work_item/2 with invalid data returns error changeset" do
      a = account_fixture()
      u = user_fixture()

      valid_attrs = @valid_attrs
      attrs = Map.merge(valid_attrs, %{user_id: u.id, account_id: a.id})
      assert {:ok, %WorkItem{} = work_item} = Costs.create_work_item(attrs)

      {:error, :work_item, %Ecto.Changeset{}, %{}} = 
        Costs.update_work_item(work_item, @invalid_attrs)
      assert same_work_items_2?(work_item, Costs.get_work_item!(work_item.id))
    end

    test "delete_work_item/1 deletes the work_item" do
      work_item = work_item_fixture()
      withdrwl_id = work_item.withdrwl.id

      {:ok, %{delete1: %Accounting.Withdrwl{}, delete2: %WorkItem{}}} = 
        Costs.delete_work_item(work_item)
      assert_raise Ecto.NoResultsError, fn -> Costs.get_work_item!(work_item.id) end
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_withdrwl!(withdrwl_id) end
    end

    test "change_work_item/1 returns a work_item changeset" do
      work_item = work_item_fixture()
      assert %Ecto.Changeset{} = Costs.change_work_item(work_item)
    end
  end
end
