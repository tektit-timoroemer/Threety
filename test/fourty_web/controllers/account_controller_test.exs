defmodule FourtyWeb.AccountControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  import Fourty.Setup
  import FourtyWeb.Gettext, only: [dgettext: 2]

  @create_attrs %{
    visible: true,
    date_end: ~D[2021-02-01],
    date_start: ~D[2021-01-01],
    label: "some label"
  }
  @update_attrs %{
    date_end: ~D[2011-05-18],
    date_start: ~D[2011-05-18],
    label: "some updated label"
  }
  @invalid_attrs %{date_end: nil, date_start: nil, label: nil, visible: nil}

  describe "test access" do
    setup [:create_account]

    test "test access - non-existing user", %{conn: conn, account: account} do

      conn = get(conn, Routes.account_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
     
      conn = get(conn, Routes.account_path(conn, :new, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      attrs = Map.merge(@create_attrs, %{client_id: 0, project_id: 0})
      conn = post(conn, Routes.account_path(conn, :create), account: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      attrs = Map.merge(@invalid_attrs, %{client_id: 0, project_id: 0})
      conn = post(conn, Routes.account_path(conn, :create), account: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.account_path(conn, :edit, account))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.account_path(conn, :update, account), account: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.account_path(conn, :update, account), account: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = delete(conn, Routes.account_path(conn, :delete, account))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
    end

    test "test access - user w/o admin rights", %{conn: conn, account: account} do
      ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")

      conn = get(conn0, Routes.account_path(conn0, :index))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")
     
      conn = get(conn0, Routes.account_path(conn0, :new, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      attrs = Map.merge(@create_attrs, %{client_id: 0, project_id: 0})
      conn = post(conn0, Routes.account_path(conn0, :create), account: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      attrs = Map.merge(@invalid_attrs, %{client_id: 0, project_id: 0})
      conn = post(conn0, Routes.account_path(conn0, :create), account: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.account_path(conn0, :edit, account))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.account_path(conn0, :update, account), account: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.account_path(conn0, :update, account), account: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = delete(conn0, Routes.account_path(conn0, :delete, account))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = delete(conn0, Routes.account_path(conn0, :delete, account))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")
    end
  end

  describe "index" do
    test "lists all accounts", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.account_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("accounts", "index")
    end
  end

  describe "new account" do
    test "renders form", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      project = project_fixture()
      conn = get(conn, Routes.account_path(conn, :new, project))
      assert html_response(conn, 200) =~ dgettext("accounts", "new")
    end
  end

  describe "create account" do
    test "redirects to show when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      project = project_fixture()
      attrs = Map.merge(@create_attrs, %{client_id: project.client_id, project_id: project.id})
      conn = post(conn, Routes.account_path(conn, :create), account: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.account_path(conn, :show, id)

      conn = get(conn, Routes.account_path(conn, :show, id))
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts", "show")
      assert html_response(conn, 200) =~ heading
      assert get_flash(conn, :info) == dgettext("accounts", "create_success")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      project = project_fixture()
      attrs = Map.merge(@invalid_attrs, %{client_id: project.client_id, project_id: project.id})
      conn = post(conn, Routes.account_path(conn, :create), account: attrs)
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts", "new")
      assert html_response(conn, 200) =~ heading
    end
  end

  describe "edit account" do
    setup [:create_account]

    test "renders form for editing chosen account", %{conn: conn, account: account} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = get(conn, Routes.account_path(conn, :edit, account))
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts", "edit")
      assert html_response(conn, 200) =~ heading
    end
  end

  describe "update account" do
    setup [:create_account]

    test "redirects when data is valid", %{conn: conn, account: account} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = put(conn, Routes.account_path(conn, :update, account), account: @update_attrs)
      assert redirected_to(conn) == Routes.account_path(conn, :show, account)

      conn = get(conn, Routes.account_path(conn, :show, account))
      assert html_response(conn, 200) =~ "some updated label"
      assert get_flash(conn, :info) == dgettext("accounts", "update_success")
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = put(conn, Routes.account_path(conn, :update, account), account: @invalid_attrs)
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts", "edit")
      assert html_response(conn, 200) =~ heading
    end
  end

  describe "delete account" do
    setup [:create_account]

    test "deletes chosen account", %{conn: conn, account: account} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = delete(conn, Routes.account_path(conn, :delete, account))
      assert redirected_to(conn) == Routes.account_path(conn, :index)
      assert get_flash(conn, :info) == dgettext("accounts", "delete_success")

      assert_error_sent 404, fn ->
        get(conn, Routes.account_path(conn, :show, account))
      end
    end
  end

  defp create_account(_) do
    account = account_fixture()
    %{account: account}
  end
end
