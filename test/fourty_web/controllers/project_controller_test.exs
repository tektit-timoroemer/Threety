defmodule FourtyWeb.ProjectControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  import Fourty.Setup
  import FourtyWeb.Gettext, only: [dgettext: 2, dgettext: 3]

  @create_attrs %{label: "some label"}
  @update_attrs %{label: "some updated label"}
  @invalid_attrs %{label: nil}

  describe "test access" do

    setup do
      client = client_fixture()
      project = project_fixture(%{client_id: client.id})
      {:ok, client: client, project: project}
    end

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

    test "list projects for given client", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      client = client_fixture()

      conn = get(conn, Routes.project_path(conn, :index_client, client.id))
      assert html_response(conn, 200) =~
               dgettext("projects", "index_client", label: client.label)
    end
  end

  describe "new project" do

    test "renders form", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      client = client_fixture()

      conn = get(conn, Routes.project_path(conn, :new, client.id))
      assert html_response(conn, 200) =~ dgettext("projects", "new")
    end
  end

  describe "create project" do
 
    test "redirects to show when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      client = client_fixture()

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

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      client = client_fixture()

      conn =
        post(conn, Routes.project_path(conn, :create),
          project: Map.merge(@invalid_attrs, %{client_id: client.id})
        )

      assert html_response(conn, 200) =~ dgettext("projects", "new")
    end
  end

  describe "edit project" do

    test "renders form for editing chosen project", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      project = project_fixture()

      conn = get(conn, Routes.project_path(conn, :edit, project))
      assert html_response(conn, 200) =~ dgettext("projects", "edit")
    end
  end

  describe "update project" do

    test "redirects when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      project = project_fixture()

      conn = put(conn, Routes.project_path(conn, :update, project), project: @update_attrs)
      assert redirected_to(conn) == Routes.project_path(conn, :show, project)

      conn = get(conn, Routes.project_path(conn, :show, project))
      assert html_response(conn, 200) =~ "some updated label"
      assert get_flash(conn, :info) == dgettext("projects", "update_success")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      project =project_fixture()

      conn = put(conn, Routes.project_path(conn, :update, project), project: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("projects", "edit")
    end
  end

  describe "delete project" do

    test "deletes chosen project", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      project = project_fixture()

      conn = delete(conn, Routes.project_path(conn, :delete, project))
      assert redirected_to(conn) == Routes.project_path(conn, :index)
      assert get_flash(conn, :info) == dgettext("projects", "delete_success")

      conn = get(conn, Routes.project_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("projects", "index")
    end
  end

end
