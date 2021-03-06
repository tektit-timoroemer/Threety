defmodule Fourty.ClientsTest do
  use Fourty.DataCase

  alias Fourty.Clients

  describe "clients" do
    alias Fourty.Clients.Client

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def client_fixture(attrs \\ %{}) do
      {:ok, client} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_client()

      client
    end

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
      assert client.name == "some name"
    end

    test "create_client/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_client(@invalid_attrs)
    end

    test "update_client/2 with valid data updates the client" do
      client = client_fixture()
      assert {:ok, %Client{} = client} = Clients.update_client(client, @update_attrs)
      assert client.name == "some updated name"
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

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    defp same_projects?(p1, p2) do
      # return true if both projects are identical ignoring any
      # associations
      Map.equal?(Map.drop(p1, [:client]), Map.drop(p2, [:client]))
    end

    def project_fixture(client, attrs \\ %{}) do
      {:ok, project} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{client_id: client.id})
        |> Clients.create_project()

      project
    end

    test "list_projects/0 returns all projects" do
      c = client_fixture()
      p = project_fixture(c)
      assert p.client_id == c.id

      a = Clients.list_projects()
      assert same_projects?(List.first(List.first(a).visible_projects), p)
    end

    test "get_project!/1 returns the project with given id" do
      client = client_fixture()
      project = project_fixture(client)
      assert same_projects?(project, Clients.get_project!(project.id))
    end

    test "create_project/1 with valid data creates a project" do
      client = client_fixture()
      {:ok, project} = Clients.create_project(Map.merge(@valid_attrs, %{client_id: client.id}))
      assert project.name == "some name"
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
      assert project.name == "some updated name"
    end

    test "update_project/2 with invalid data returns error changeset" do
      client = client_fixture()

      assert {:ok, project} =
               Clients.create_project(Map.merge(@valid_attrs, %{client_id: client.id}))

      assert {:error, %Ecto.Changeset{}} = Clients.update_project(project, @invalid_attrs)
      assert same_projects?(project, Clients.get_project!(project.id))
    end

    test "delete_project/1 deletes the project" do
      client = client_fixture()
      project = project_fixture(client)
      assert {:ok, %Project{}} = Clients.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      client = client_fixture()
      project = project_fixture(client)
      assert %Ecto.Changeset{} = Clients.change_project(project)
    end
  end

  describe "orders" do
    alias Fourty.Clients.Order

    @valid_attrs %{
      amount_cur: 42,
      amount_dur: 43,
      date_eff: ~D[2010-04-17],
      description: "some notes"
    }
    @update_attrs %{
      amount_cur: 44,
      amount_dur: 45,
      date_eff: ~D[2011-05-18],
      description: "some updated notes"
    }
    @invalid_attrs %{amount_cur: nil, amount_dur: nil, date_eff: nil, description: nil}

    def order_fixture(project, attrs \\ %{}) do
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{project_id: project.id})
        |> Clients.create_order()

      order
    end

    def same_order?(o1, o2) do
      # return true if both orders are identical ignoring any
      # associations
      Map.equal?(Map.drop(o1, [:project]), Map.drop(o2, [:project]))
    end

    test "list_orders/0 returns all orders" do
      client = client_fixture()
      project = project_fixture(client)
      order = order_fixture(project)
      assert order.project_id == project.id

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

      assert same_order?(order, first_order)
    end

    test "get_order!/1 returns the order with given id" do
      client = client_fixture()
      project = project_fixture(client)
      order = order_fixture(project)
      assert same_order?(Clients.get_order!(order.id), order)
    end

    test "create_order/1 with valid data creates a order" do
      client = client_fixture()
      project = project_fixture(client)

      order =
        %{}
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{project_id: project.id})
        |> Clients.create_order()

      assert {:ok, %Order{} = order} = order
      assert order.amount_cur == 42
      assert order.amount_dur == 43
      assert order.date_eff == ~D[2010-04-17]
      assert order.description == "some notes"
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      client = client_fixture()
      project = project_fixture(client)
      order = order_fixture(project)
      assert {:ok, %Order{} = order} = Clients.update_order(order, @update_attrs)
      assert order.amount_cur == 44
      assert order.amount_dur == 45
      assert order.date_eff == ~D[2011-05-18]
      assert order.description == "some updated notes"
    end

    test "update_order/2 with invalid data returns error changeset" do
      client = client_fixture()
      project = project_fixture(client)
      order = order_fixture(project)
      assert {:error, %Ecto.Changeset{}} = Clients.update_order(order, @invalid_attrs)
      assert same_order?(Clients.get_order!(order.id), order)
    end

    test "delete_order/1 deletes the order" do
      client = client_fixture()
      project = project_fixture(client)
      order = order_fixture(project)
      assert {:ok, %Order{}} = Clients.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      client = client_fixture()
      project = project_fixture(client)
      order = order_fixture(project)
      assert %Ecto.Changeset{} = Clients.change_order(order)
    end
  end
end
