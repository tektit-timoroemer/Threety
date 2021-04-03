defmodule Fourty.ClientsTest do
  use Fourty.DataCase

  import Fourty.Setup
  alias Fourty.Clients

  describe "clients" do
    alias Fourty.Clients.Client

    @valid_attrs %{label: "some label"}
    @update_attrs %{label: "some updated label"}
    @invalid_attrs %{label: nil}

    test "list_clients/0 returns all clients" do
      client = client_fixture()
      assert Clients.list_clients() == [client]
    end

    test "get_client!/1 returns the client with given id" do
      client = client_fixture()
      assert Clients.get_client!(client.id) == client
    end

    test "create_client/1 with valid data creates a client" do
      assert {:ok, %Client{} = client} = Clients.create_client(@valid_attrs)
      assert client.label == "some label"
    end

    test "create_client/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_client(@invalid_attrs)
    end

    test "update_client/2 with valid data updates the client" do
      client = client_fixture()
      assert {:ok, %Client{} = client} = Clients.update_client(client, @update_attrs)
      assert client.label == "some updated label"
    end

    test "update_client/2 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_client(client, @invalid_attrs)
      assert client == Clients.get_client!(client.id)
    end

    test "delete_client/1 deletes the client" do
      client = client_fixture()
      assert {:ok, %Client{}} = Clients.delete_client(client)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_client!(client.id) end
    end

    test "change_client/1 returns a client changeset" do
      client = client_fixture()
      assert %Ecto.Changeset{} = Clients.change_client(client)
    end
  end

  describe "projects" do
    alias Fourty.Clients.Project

    @valid_attrs %{label: "some label"}
    @update_attrs %{label: "some updated label"}
    @invalid_attrs %{label: nil}

    test "list_projects/0 returns all projects" do
      c = client_fixture()
      p = project_fixture(%{client_id: c.id})
      assert p.client_id == c.id
      a = Clients.list_projects()
      assert same_projects?(List.first(List.first(a).visible_projects), p)
    end

    test "get_project!/1 returns the project with given id" do
      c = client_fixture()
      p = project_fixture(%{client_id: c.id})
      assert same_projects?(p, Clients.get_project!(p.id))
    end

    test "create_project/1 with valid data creates a project" do
      client = client_fixture()
      {:ok, project} = Clients.create_project(Map.merge(@valid_attrs, %{client_id: client.id}))
      assert project.label == "some label"
      assert project.client_id == client.id
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_project(@invalid_attrs)
    end

    test "create_project/1 with missing association" do
      # for some strange reason, this test case does not fail as intended:
      # postgres has a constraint set but the postgres error is not
      # reflected to the Ecto.Changeset.
      # >assert {:error, %Ecto.Changeset{}} = Clients.create_project(@valid_attrs)
      Clients.create_project(@valid_attrs)
      assert Enum.empty?(Clients.list_projects())
    end

    test "update_project/2 with valid data updates the project" do
      client = client_fixture()

      assert {:ok, project} =
               Clients.create_project(Map.merge(@valid_attrs, %{client_id: client.id}))

      assert {:ok, %Project{} = project} = Clients.update_project(project, @update_attrs)
      assert project.label == "some updated label"
    end

    test "update_project/2 with invalid data returns error changeset" do
      client = client_fixture()

      assert {:ok, project} =
               Clients.create_project(Map.merge(@valid_attrs, %{client_id: client.id}))

      assert {:error, %Ecto.Changeset{}} = Clients.update_project(project, @invalid_attrs)
      assert same_projects?(project, Clients.get_project!(project.id))
    end

    test "delete_project/1 deletes the project" do
      c = client_fixture()
      p = project_fixture(%{client_id: c.id})
      assert {:ok, %Project{}} = Clients.delete_project(p)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_project!(p.id) end
    end

    test "change_project/1 returns a project changeset" do
      c = client_fixture()
      p = project_fixture(%{client_id: c.id})
      assert %Ecto.Changeset{} = Clients.change_project(p)
    end
  end

  describe "orders" do
    alias Fourty.Clients.Order

    @valid_attrs %{
      amount_cur: 42,
      amount_dur: 43,
      date_eff: ~D[2010-04-17],
      label: "some notes"
    }
    @update_attrs %{
      amount_cur: 44,
      amount_dur: 45,
      date_eff: ~D[2011-05-18],
      label: "some updated notes"
    }
    @invalid_attrs %{amount_cur: nil, amount_dur: nil, date_eff: nil, label: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      [
        %Fourty.Clients.Client{
          visible_projects: [
            %Fourty.Clients.Project{
              orders: [first_order | _]
            }
            | _
          ]
        }
        | _
      ] = Clients.list_orders()
      assert same_orders?(order, first_order)
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert same_orders?(Clients.get_order!(order.id), order)
    end

    test "create_order/1 with valid data creates a order" do
      c = client_fixture()
      p = project_fixture(%{client_id: c.id})

      o =
        %{}
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{project_id: p.id})
        |> Clients.create_order()

      assert {:ok, %Order{} = o} = o
      assert o.amount_cur == 42
      assert o.amount_dur == 43
      assert o.date_eff == ~D[2010-04-17]
      assert o.label == "some notes"
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, %Order{} = order} = Clients.update_order(order, @update_attrs)
      assert order.amount_cur == 44
      assert order.amount_dur == 45
      assert order.date_eff == ~D[2011-05-18]
      assert order.label == "some updated notes"
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_order(order, @invalid_attrs)
      assert same_orders?(Clients.get_order!(order.id), order)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Clients.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Clients.change_order(order)
    end
  end
end
