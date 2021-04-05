defmodule FourtyWeb.OrderControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  import Fourty.Setup
  import FourtyWeb.Gettext, only: [dgettext: 2, dgettext: 3]

  @create_attrs %{amount: 42, date: ~D[2010-04-17], label: "some label"}
  @update_attrs %{amount: 43, date: ~D[2011-05-18], label: "some updated label"}
  @invalid_attrs %{amount: nil, date: nil, label: nil}

  describe "test access" do
    
    test "test access - non-existing user", %{conn: conn} do
      conn = get(conn, Routes.order_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.order_path(conn, :index_account, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.order_path(conn, :index_project, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.order_path(conn, :index_client, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.order_path(conn, :new, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = post(conn, Routes.order_path(conn, :create), order: @create_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = post(conn, Routes.order_path(conn, :create), order: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.order_path(conn, :edit, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.order_path(conn, :update, 0), order: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.order_path(conn, :update, 0), order: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
 
      conn = delete(conn, Routes.order_path(conn, :delete, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
    end

    test "test access - user w/o admin rights", %{conn: conn} do
      ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")

      conn = get(conn0, Routes.order_path(conn0, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.order_path(conn0, :index_account, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.order_path(conn0, :index_project, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.order_path(conn0, :index_client, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.order_path(conn0, :new, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = post(conn0, Routes.order_path(conn0, :create), order: @create_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = post(conn0, Routes.order_path(conn0, :create), order: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.order_path(conn0, :edit, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.order_path(conn0, :update, 0), order: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn, Routes.order_path(conn, :update, 0), order: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")
 
      conn = delete(conn0, Routes.order_path(conn0, :delete, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")
    end

  end

  describe "various index listings" do

    setup do
      client = client_fixture()
      project = project_fixture(%{client_id: client.id})
      account = account_fixture(%{project_id: project.id})
      order = order_fixture(%{project_id: project.id})
      {:ok, order: order, project: project, account: account, client: client}
    end

    test "lists all orders", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.order_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("orders", "index")
    end

    test "lists all orders for given account",
      %{conn: conn, account: account} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.order_path(conn, :index_account, account.id))
      assert html_response(conn, 200) =~
        dgettext("orders", "index_account", label: account.label)

      # some other account

      account = account_fixture()
      conn = get(conn, Routes.order_path(conn, :index_account, account.id))
      assert html_response(conn, 200) =~
        dgettext("orders", "index_account", label: account.label)
    end

    test "lists all orders for given project",
      %{conn: conn, project: project} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.order_path(conn, :index_project, project.id))
      assert html_response(conn, 200) =~
        dgettext("orders", "index_project", label: project.label)

      # some other project

      project = project_fixture()
      conn = get(conn, Routes.order_path(conn, :index_project, project.id))
      assert html_response(conn, 200) =~
        dgettext("orders", "index_project", label: project.label)
    end

    test "lists all orders for given client",
      %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.order_path(conn, :index_client, client.id))
      assert html_response(conn, 200) =~
        dgettext("orders", "index_client", label: client.label)

      # some other client

      client = client_fixture()

      conn = get(conn, Routes.order_path(conn, :index_client, client.id))
      assert html_response(conn, 200) =~
        dgettext("orders", "index_client", label: client.label)
    end

  end

  describe "new order" do
    test "renders form", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.order_path(conn, :new, project_fixture().id))
      assert html_response(conn, 200) =~ dgettext("orders", "new")
    end
  end

  describe "create order" do

    test "redirects to show when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      project = project_fixture()

      attrs = Map.merge(@create_attrs, %{project_id: project.id})
      conn = post(conn, Routes.order_path(conn, :create), order: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.order_path(conn, :show, id)

      conn = get(conn, Routes.order_path(conn, :show, id))
      assert html_response(conn, 200) =~ dgettext("orders", "show")
      assert get_flash(conn, :info) == dgettext("orders", "create_success")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      project = project_fixture()

      attrs = Map.merge(@invalid_attrs, %{project_id: project.id})
      conn = post(conn, Routes.order_path(conn, :create), order: attrs)
      assert html_response(conn, 200) =~ dgettext("orders", "new")
    end
  end

  describe "edit order" do

    test "renders form for editing chosen order", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      order = order_fixture()

      conn = get(conn, Routes.order_path(conn, :edit, order.id))
      assert html_response(conn, 200) =~ dgettext("orders", "edit")
    end
  end

  describe "update order" do

    test "redirects when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      order = order_fixture()

      conn = put(conn, Routes.order_path(conn, :update, order), order: @update_attrs)
      assert redirected_to(conn) == Routes.order_path(conn, :show, order)

      conn = get(conn, Routes.order_path(conn, :show, order))
      assert html_response(conn, 200) =~ dgettext("orders", "show")
      assert get_flash(conn, :info) == dgettext("orders", "update_success")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      order = order_fixture()

      conn = put(conn, Routes.order_path(conn, :update, order), order: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("orders", "edit")
    end
  end

  describe "delete order" do

    test "deletes chosen order", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      order = order_fixture()

      conn = delete(conn, Routes.order_path(conn, :delete, order))
      assert redirected_to(conn) == Routes.order_path(conn, :index)
      assert get_flash(conn, :info) == dgettext("orders", "delete_success")

      assert_error_sent 404, fn ->
        get(conn, Routes.order_path(conn, :show, order))
      end
    end
  end

end
