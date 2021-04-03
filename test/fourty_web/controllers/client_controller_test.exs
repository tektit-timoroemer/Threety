defmodule FourtyWeb.ClientControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  import Fourty.Setup
  import FourtyWeb.Gettext, only: [dgettext: 2]

  @create_attrs %{label: "some label"}
  @update_attrs %{label: "some updated label"}
  @invalid_attrs %{label: nil}

  describe "test access" do
    setup [:create_client]

    test "test access - non-existing user", %{conn: conn, client: client} do
      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.client_path(conn, :show, client))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.client_path(conn, :new))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = post(conn, Routes.client_path(conn, :create), client: @create_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.client_path(conn, :edit, client))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.client_path(conn, :update, client), client: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
    end

    test "test access - user w/o admin rights", %{conn: conn, client: client} do
      ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")

      conn = get(conn0, Routes.client_path(conn0, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.client_path(conn0, :show, client))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.client_path(conn0, :new))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = post(conn0, Routes.client_path(conn0, :create), client: @create_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.client_path(conn0, :edit, client))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.client_path(conn0, :update, client), client: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.client_path(conn0, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")
    end
  end

  describe "index" do
    test "lists all clients", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("clients", "index")
    end
  end

  describe "show" do
    setup [:create_client]

    test "show data for a specific client", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.client_path(conn, :show, client))
      assert html_response(conn, 200) =~ dgettext("clients", "show")
    end

    test "show non-existing client", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      # this will fail due to get_client! failure
      c = Map.replace(client, :id, 0)
      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.client_path(conn, :show, c))
      end
    end
  end

  describe "new client" do
    test "renders form", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.client_path(conn, :new))
      assert html_response(conn, 200) =~ dgettext("clients", "new")
    end
  end

  describe "create client" do
    test "redirects to index when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = post(conn, Routes.client_path(conn, :create), client: @create_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.client_path(conn, :show, id)
      assert get_flash(conn, :info) == dgettext("clients", "create_success")

      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("clients", "index")
      assert get_flash(conn, :info) == dgettext("clients", "create_success")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = post(conn, Routes.client_path(conn, :create), client: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("errors", "error_alert")
      assert html_response(conn, 200) =~ dgettext("clients", "new")
    end
  end

  describe "edit client" do
    setup [:create_client]

    test "renders form for editing chosen client", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.client_path(conn, :edit, client))
      assert html_response(conn, 200) =~ dgettext("clients", "edit")
    end
  end

  describe "update client" do
    setup [:create_client]

    test "redirects when data is valid", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = put(conn, Routes.client_path(conn, :update, client), client: @update_attrs)
      assert redirected_to(conn) == Routes.client_path(conn, :index)
      assert get_flash(conn, :info) == dgettext("clients", "update_success")

      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ "some updated label"
      assert get_flash(conn, :info) == dgettext("clients", "update_success")
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = put(conn, Routes.client_path(conn, :update, client), client: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("errors", "error_alert")
      assert html_response(conn, 200) =~ dgettext("clients", "edit")
    end
  end

  describe "delete client" do
    setup [:create_client]

    test "deletes chosen client", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = delete(conn, Routes.client_path(conn, :delete, client))
      assert redirected_to(conn) == Routes.client_path(conn, :index)
      assert get_flash(conn, :info) == dgettext("clients", "delete_success")

      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("clients", "index")
    end

    test "delete non-existing client", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      # this will fail due to get_client! failure
      c = Map.replace(client, :id, 0)

      assert_raise Ecto.NoResultsError, fn ->
        delete(conn, Routes.client_path(conn, :delete, c))
      end
    end
  end

  defp create_client(_) do
    client = client_fixture()
    %{client: client}
  end
end
