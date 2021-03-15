defmodule FourtyWeb.ProjectControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  import FourtyWeb.Gettext, only: [dgettext: 2, dgettext: 3]
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

  describe "test access" do
    setup [:create_project]

    test "test access - non-existing user",
      %{conn: conn, client: client, project: project} do

      conn = get(conn, Routes.project_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
      
      conn = get(conn, Routes.project_path(conn, :index_client, client.id))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.project_path(conn, :new, client.id))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = post(conn, Routes.project_path(conn, :create),
          project: Map.merge(@create_attrs, %{client_id: client.id}))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = post(conn, Routes.project_path(conn, :create),
          project: Map.merge(@invalid_attrs, %{client_id: client.id}))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.project_path(conn, :edit, project))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.project_path(conn, :update, project), project: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.project_path(conn, :update, project), project: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = delete(conn, Routes.project_path(conn, :delete, project))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
    end

    test "test access - user w/o admin rights",
      %{conn: conn, client: client, project: project} do

      ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")

      conn = get(conn0, Routes.project_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")
      
      conn = get(conn0, Routes.project_path(conn, :index_client, client.id))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.project_path(conn, :new, client.id))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = post(conn0, Routes.project_path(conn, :create),
          project: Map.merge(@create_attrs, %{client_id: client.id}))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = post(conn0, Routes.project_path(conn, :create),
          project: Map.merge(@invalid_attrs, %{client_id: client.id}))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.project_path(conn, :edit, project))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.project_path(conn, :update, project), project: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.project_path(conn, :update, project), project: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = delete(conn0, Routes.project_path(conn, :delete, project))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")
    end
  end

  describe "index" do
    test "lists all projects", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = get(conn, Routes.project_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("projects", "index")
    end
  end

  describe "index_client" do
    setup [:create_client]

    test "list projects for given client", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.project_path(conn, :index_client, client.id))
      assert html_response(conn, 200) =~
               dgettext("projects", "index_client", name: "some client name")
    end
  end

  describe "new project" do
    setup [:create_client]

    test "renders form", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.project_path(conn, :new, client.id))
      assert html_response(conn, 200) =~ dgettext("projects", "new")
    end
  end

  describe "create project" do
    setup [:create_client]

    test "redirects to show when data is valid", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn =
        post(conn, Routes.project_path(conn, :create),
          project: Map.merge(@create_attrs, %{client_id: client.id})
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.project_path(conn, :show, id)

      conn = get(conn, Routes.project_path(conn, :show, id))
      assert html_response(conn, 200) =~ dgettext("projects", "show")
      assert get_flash(conn, :info) == dgettext("projects", "create_success")
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn =
        post(conn, Routes.project_path(conn, :create),
          project: Map.merge(@invalid_attrs, %{client_id: client.id})
        )

      assert html_response(conn, 200) =~ dgettext("projects", "new")
    end
  end

  describe "edit project" do
    setup [:create_project]

    test "renders form for editing chosen project", %{conn: conn, project: project} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = get(conn, Routes.project_path(conn, :edit, project))
      assert html_response(conn, 200) =~ dgettext("projects", "edit")
    end
  end

  describe "update project" do
    setup [:create_project]

    test "redirects when data is valid", %{conn: conn, project: project} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = put(conn, Routes.project_path(conn, :update, project), project: @update_attrs)
      assert redirected_to(conn) == Routes.project_path(conn, :show, project)

      conn = get(conn, Routes.project_path(conn, :show, project))
      assert html_response(conn, 200) =~ "some updated name"
      assert get_flash(conn, :info) == dgettext("projects", "update_success")
    end

    test "renders errors when data is invalid", %{conn: conn, project: project} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = put(conn, Routes.project_path(conn, :update, project), project: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("projects", "edit")
    end
  end

  describe "delete project" do
    setup [:create_project]

    test "deletes chosen project", %{conn: conn, project: project} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = delete(conn, Routes.project_path(conn, :delete, project))
      assert redirected_to(conn) == Routes.project_path(conn, :index)
      assert get_flash(conn, :info) == dgettext("projects", "delete_success")

      conn = get(conn, Routes.project_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("projects", "index")
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
