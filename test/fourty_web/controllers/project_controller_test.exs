defmodule FourtyWeb.ProjectControllerTest do
  use FourtyWeb.ConnCase
  import FourtyWeb.Gettext
  alias Fourty.Clients

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  @client_create_attrs %{name: "some client name"}

  def fixture(:client) do
    {:ok, client} = Clients.create_client(@client_create_attrs)
    client
  end

  def fixture(:project, client) do
    {:ok, project} = Clients.create_project(Map.merge(@create_attrs, %{client_id: client.id}))
    project
  end

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, Routes.project_path(conn,:index))
      assert html_response(conn, 200) =~ dgettext("projects","index")
    end
  end

  describe "index_client" do
    setup [:create_client]
    test "list projects for given client", %{conn: conn, client: client} do
      conn = get(conn, Routes.project_path(conn, :index_client, client.id))
      assert html_response(conn, 200) =~ dgettext("projects","index_client", name: "some client name")
    end
  end

  describe "new project" do
    setup [:create_client]
    test "renders form", %{conn: conn, client: client} do
      conn = get(conn, Routes.project_path(conn, :new, client.id))
      assert html_response(conn, 200) =~ dgettext("projects","add")
    end
  end

  describe "create project" do
    setup [:create_client]

    test "redirects to show when data is valid", %{conn: conn, client: client} do
      conn = post(conn, Routes.project_path(conn, :create), project: Map.merge(@create_attrs, %{client_id: client.id}))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.project_path(conn, :show, id)

      conn = get(conn, Routes.project_path(conn, :show, id))
      assert html_response(conn, 200) =~ dgettext("projects","show")
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      conn = post(conn, Routes.project_path(conn, :create), project: Map.merge(@invalid_attrs, %{client_id: client.id}))
      assert html_response(conn, 200) =~ dgettext("projects","add")
    end
  end

  describe "edit project" do
    setup [:create_project]

    test "renders form for editing chosen project", %{conn: conn, project: project} do
      conn = get(conn, Routes.project_path(conn, :edit, project))
      assert html_response(conn, 200) =~ dgettext("projects","edit")
    end
  end

  describe "update project" do
    setup [:create_project]

    test "redirects when data is valid", %{conn: conn, project: project} do
      conn = put(conn, Routes.project_path(conn, :update, project), project: @update_attrs)
      assert redirected_to(conn) == Routes.project_path(conn, :show, project)

      conn = get(conn, Routes.project_path(conn, :show, project))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, project: project} do
      conn = put(conn, Routes.project_path(conn, :update, project), project: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("projects","edit")
    end
  end

  describe "delete project" do
    setup [:create_project]

    test "deletes chosen project", %{conn: conn, project: project} do
      conn = delete(conn, Routes.project_path(conn, :delete, project))
      assert redirected_to(conn) == Routes.project_path(conn, :index)

      conn = get(conn, Routes.project_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("projects","index")
    end
  end

  defp create_project(_) do
    client = fixture(:client)
    project = fixture(:project, client)
    %{client: client, project: project}
  end

  defp create_client(_) do
    client = fixture(:client)
    %{client: client}
  end
end
