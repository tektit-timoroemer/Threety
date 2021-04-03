defmodule FourtyWeb.DepositControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  import Fourty.Setup
  import FourtyWeb.Gettext, only: [dgettext: 2, dgettext: 3]

  @create_attrs %{amount_cur: 42, amount_dur: 43, label: "a deposit"}
  @update_attrs %{amount_cur: 44, amount_dur: 45, label: "another deposit"}
  @invalid_attrs %{amount_cur: nil, amount_dur: nil, label: nil}

  describe "test access" do

    test "test access - non-existing user", %{conn: conn} do
      conn = get(conn, Routes.deposit_path(conn, :index_account, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.deposit_path(conn, :index_order, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.deposit_path(conn, :new, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      attrs = Map.merge(@create_attrs, %{account_id: 0, order_id: 0})
      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      attrs = Map.merge(@invalid_attrs, %{account_id: 0, order_id: 0})
      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.deposit_path(conn, :edit, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.deposit_path(conn, :update, 0), deposit: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.deposit_path(conn, :update, 0), deposit: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = delete(conn, Routes.deposit_path(conn, :delete, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
    end

    test "test access - user w/o admin rights", %{conn: conn} do
      ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")

      conn = get(conn0, Routes.deposit_path(conn, :index_account, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.deposit_path(conn, :index_order, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.deposit_path(conn, :new, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      attrs = Map.merge(@create_attrs, %{account_id: 0, order_id: 0})
      conn = post(conn0, Routes.deposit_path(conn, :create), deposit: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      attrs = Map.merge(@invalid_attrs, %{account_id: 0, order_id: 0})
      conn = post(conn0, Routes.deposit_path(conn, :create), deposit: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.deposit_path(conn, :edit, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.deposit_path(conn, :update, 0), deposit: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.deposit_path(conn, :update, 0), deposit: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = delete(conn0, Routes.deposit_path(conn, :delete, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")
    end
  end

  describe "index_account" do
    test "lists all deposits for given account", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      account = account_fixture()
      conn = get(conn, Routes.deposit_path(conn, :index_account, account.id))
      assert html_response(conn, 200) =~ dgettext("deposits", "index_account", label: account.label)
    end
  end

  describe "index_order" do
    test "lists all deposits for given order", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      order = order_fixture()
      conn = get(conn, Routes.deposit_path(conn, :index_order, order.id))

      assert html_response(conn, 200) =~
               dgettext("deposits", "index_order", label: order.label)
    end
  end

  describe "new deposit" do
    test "renders form", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      order = order_fixture()
      conn = get(conn, Routes.deposit_path(conn, :new, order.id))
      assert html_response(conn, 200) =~ dgettext("deposits", "new")
    end
  end

  describe "create deposit" do
    test "redirects to show when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      order = order_fixture()
      attrs = Map.merge(@create_attrs, %{account_id: order.account_id, order_id: order.id})
      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.deposit_path(conn, :show, id)

      conn = get(conn, Routes.deposit_path(conn, :show, id))
      assert html_response(conn, 200) =~ dgettext("deposits", "show")
      assert get_flash(conn, :info) == dgettext("deposits", "create_success")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      order = order_fixture()
      attrs = Map.merge(@invalid_attrs, %{account_id: order.account_id, order_id: order.id})
      conn = post(conn, Routes.deposit_path(conn, :create), deposit: attrs)
      assert html_response(conn, 200) =~ dgettext("deposits", "new")
    end
  end

  describe "edit deposit" do
    setup [:create_deposit]

    test "renders form for editing chosen deposit", %{conn: conn, deposit: deposit} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = get(conn, Routes.deposit_path(conn, :edit, deposit))
      assert html_response(conn, 200) =~ dgettext("deposits", "edit")
    end
  end

  describe "update deposit" do
    setup [:create_deposit]

    test "redirects when data is valid", %{conn: conn, deposit: deposit} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = put(conn, Routes.deposit_path(conn, :update, deposit), deposit: @update_attrs)
      assert redirected_to(conn) == Routes.deposit_path(conn, :show, deposit)

      conn = get(conn, Routes.deposit_path(conn, :show, deposit))
      assert html_response(conn, 200)
      assert get_flash(conn, :info) == dgettext("deposits", "update_success")
    end

    test "renders errors when data is invalid", %{conn: conn, deposit: deposit} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = put(conn, Routes.deposit_path(conn, :update, deposit), deposit: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Deposit"
    end
  end

  describe "delete deposit" do
    setup [:create_deposit]

    test "deletes chosen deposit", %{conn: conn, deposit: deposit} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = delete(conn, Routes.deposit_path(conn, :delete, deposit))
      assert redirected_to(conn) == Routes.deposit_path(conn, :index_account, deposit.account_id)
      assert get_flash(conn, :info) == dgettext("deposits", "delete_success")

      assert_error_sent 404, fn ->
        get(conn, Routes.deposit_path(conn, :show, deposit))
      end
    end
  end

  defp create_deposit(_) do
    deposit = deposit_fixture()
    %{deposit: deposit}
  end
end
