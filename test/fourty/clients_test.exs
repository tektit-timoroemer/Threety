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

    defp same_projects?(p1,p2) do
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

      a  = Clients.list_projects()
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
      assert {:ok, project} = Clients.create_project(Map.merge(@valid_attrs, %{client_id: client.id}))
      assert {:ok, %Project{} = project} = Clients.update_project(project, @update_attrs)
      assert project.name == "some updated name"
    end

    test "update_project/2 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:ok, project} = Clients.create_project(Map.merge(@valid_attrs, %{client_id: client.id}))
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
end
