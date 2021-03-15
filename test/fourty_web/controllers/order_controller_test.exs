defmodule FourtyWeb.OrderControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  import FourtyWeb.Gettext, only: [dgettext: 2, dgettext: 3]
  alias Fourty.Clients

  @create_attrs %{amount: 42, date: ~D[2010-04-17], description: "some description"}
  @update_attrs %{amount: 43, date: ~D[2011-05-18], description: "some updated description"}
  @invalid_attrs %{amount: nil, date: nil, description: nil}

  def fixture(:client) do
    {:ok, client} = Clients.create_client(%{name: "test client"})
    client
  end

  def fixture(:project) do
    {:ok, project} =
      Clients.create_project(%{name: "test project", client_id: fixture(:client).id})
    project
  end

  def fixture(:account) do
    {:ok, account} = Fourty.Accounting.create_account(%{
      name: "test account", project_id: fixture(:project).id})
    account
  end

  def fixture(:order) do
    attrs = Map.merge(@create_attrs, %{project_id: fixture(:project).id})
    {:ok, order} = Clients.create_order(attrs)
    order
  end

  defp create_fixtures(_) do
    {:ok, client}  = Clients.create_client(%{
      name: "test client"})
    {:ok, project} = Clients.create_project(%{
      name: "test project", client_id: client.id})
    {:ok, account} = Fourty.Accounting.create_account(%{
      name: "test account", project_id: project.id})
    attrs = Map.merge(@create_attrs, %{project_id: project.id})
    {:ok, order} = Clients.create_order(attrs)
    %{client: client, project: project, account: account, order: order}
  end

  defp create_order(_) do
    order = fixture(:order)
    %{order: order}
  end

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
    setup [:create_fixtures]

    test "lists all orders", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.order_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("orders", "index")
    end

    test "lists all orders for given account", %{conn: conn, account: account} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = get(conn, Routes.order_path(conn, :index_account, account.id))
      assert html_response(conn, 200) =~ dgettext("orders", "index_account", name: "test account")
    end

    test "lists all orders for given project", %{conn: conn, project: project} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = get(conn, Routes.order_path(conn, :index_project, project.id))
      assert html_response(conn, 200) =~ dgettext("orders", "index_project", name: "test project")
    end

    test "lists all orders for given client", %{conn: conn, client: client} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = get(conn, Routes.order_path(conn, :index_client, client.id))
      assert html_response(conn, 200) =~ dgettext("orders", "index_client", name: "test client")
    end

  end

  describe "new order" do
    test "renders form", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.order_path(conn, :new, fixture(:project).id))
      assert html_response(conn, 200) =~ dgettext("orders", "new")
    end
  end

  describe "create order" do

    test "redirects to show when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")


      attrs = Map.merge(@create_attrs, %{project_id: fixture(:project).id})
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

      attrs = Map.merge(@invalid_attrs, %{project_id: fixture(:project).id})
      conn = post(conn, Routes.order_path(conn, :create), order: attrs)
      assert html_response(conn, 200) =~ dgettext("orders", "new")
    end
  end

  describe "edit order" do
    setup [:create_order]

    test "renders form for editing chosen order", %{conn: conn, order: order} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.order_path(conn, :edit, order))
      assert html_response(conn, 200) =~ dgettext("orders", "edit")
    end
  end

  describe "update order" do
    setup [:create_order]

    test "redirects when data is valid", %{conn: conn, order: order} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = put(conn, Routes.order_path(conn, :update, order), order: @update_attrs)
      assert redirected_to(conn) == Routes.order_path(conn, :show, order)

      conn = get(conn, Routes.order_path(conn, :show, order))
      assert html_response(conn, 200) =~ dgettext("orders", "show")
      assert get_flash(conn, :info) == dgettext("orders", "update_success")
    end

    test "renders errors when data is invalid", %{conn: conn, order: order} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = put(conn, Routes.order_path(conn, :update, order), order: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("orders", "edit")
    end
  end

  describe "delete order" do
    setup [:create_order]

    test "deletes chosen order", %{conn: conn, order: order} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = delete(conn, Routes.order_path(conn, :delete, order))
      assert redirected_to(conn) == Routes.order_path(conn, :index)
      assert get_flash(conn, :info) == dgettext("orders", "delete_success")

      assert_error_sent 404, fn ->
        get(conn, Routes.order_path(conn, :show, order))
      end
    end
  end

end
