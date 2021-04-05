defmodule FourtyWeb.WithdrawalControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  import Fourty.Setup
  import FourtyWeb.Gettext, only: [dgettext: 2, dgettext: 3]

  @create_attrs %{amount_cur: 42, amount_dur: 43, label: "a withdrawal"}
  @update_attrs %{amount_cur: 44, amount_dur: 45, label: "another withdrawal"}
  @invalid_attrs %{amount_cur: nil, amount_dur: nil, label: nil}

  describe "test access" do
    
    test "non-existing user", %{conn: conn} do
      conn = get(conn, Routes.withdrawal_path(conn, :index_account, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.withdrawal_path(conn, :new))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      attrs = Map.merge(@create_attrs, %{account_id: 0, work_item_id: 0})
      conn = post(conn, Routes.withdrawal_path(conn, :create), withdrawal: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      attrs = Map.merge(@invalid_attrs, %{account_id: 0, work_item_id: 0})
      conn = post(conn, Routes.withdrawal_path(conn, :create, withdrawal: attrs))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.withdrawal_path(conn, :edit, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.withdrawal_path(conn, :update, 0), withdrawal: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.withdrawal_path(conn, :update, 0), withdrawal: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = delete(conn, Routes.withdrawal_path(conn, :delete, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
    end

    test "user w/o admin rights", %{conn: conn} do
      ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")

      conn = get(conn0, Routes.withdrawal_path(conn0, :index_account, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.withdrawal_path(conn0, :new))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      attrs = Map.merge(@create_attrs, %{account_id: 0, work_item_id: 0})
      conn = post(conn0, Routes.withdrawal_path(conn0, :create), withdrawal: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      attrs = Map.merge(@invalid_attrs, %{account_id: 0, work_item_id: 0})
      conn = post(conn0, Routes.withdrawal_path(conn0, :create, withdrawal: attrs))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = get(conn0, Routes.withdrawal_path(conn0, :edit, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.withdrawal_path(conn0, :update, 0), withdrawal: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = put(conn0, Routes.withdrawal_path(conn0, :update, 0), withdrawal: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

      conn = delete(conn0, Routes.withdrawal_path(conn0, :delete, 0))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "insufficient_access_rights")

    end
  end

  describe "index_account" do
    test "lists all withdrawals for a given account", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      account = account_fixture()

      # nothing to list

      conn = get(conn, Routes.withdrawal_path(conn, :index_account, account.id))
      assert html_response(conn, 200) =~
        dgettext("withdrawals", "index_account", label: account.label)

      # something to list

      withdrawal_fixture(%{account_id: account.id})
      conn = get(conn, Routes.withdrawal_path(conn, :index_account, account.id))
      assert html_response(conn, 200) =~
        dgettext("withdrawals", "index_account", label: account.label)

      # other account

      account = account_fixture()
      conn = get(conn, Routes.withdrawal_path(conn, :index_account, account.id))
      assert html_response(conn, 200) =~
        dgettext("withdrawals", "index_account", label: account.label)
    end
  end

  describe "new withdrawal" do
    test "renders form", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      account = account_fixture()

      conn = get(conn, Routes.withdrawal_path(conn, :new, account_id: account.id))
      assert html_response(conn, 200) =~ dgettext("withdrawals", "new")
    end
  end

  describe "create withdrwl" do
    test "redirects to show when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      account = account_fixture()

      attrs = Map.merge(@create_attrs, %{account_id: account.id})      
      conn = post(conn, Routes.withdrawal_path(conn, :create), withdrawal: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.withdrawal_path(conn, :show, id)

      conn = get(conn, Routes.withdrawal_path(conn, :show, id))
      assert html_response(conn, 200) =~ dgettext("withdrawals", "show")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")

      conn = post(conn, Routes.withdrawal_path(conn, :create), withdrawal: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("withdrawals", "new")
    end
  end

  describe "edit withdrwl" do
    test "renders form for editing chosen withdrwl", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      withdrawal = withdrawal_fixture()

      conn = get(conn, Routes.withdrawal_path(conn, :edit, withdrawal.id))
      assert html_response(conn, 200) =~ dgettext("withdrawals", "edit")
    end
  end

  describe "update withdrwl" do

    test "redirects when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      withdrawal = withdrawal_fixture()

      conn = put(conn, Routes.withdrawal_path(conn, :update, withdrawal), withdrawal: @update_attrs)
      assert redirected_to(conn) == Routes.withdrawal_path(conn, :show, withdrawal.id)

      conn = get(conn, Routes.withdrawal_path(conn, :show, withdrawal.id))
      assert html_response(conn, 200) =~ @update_attrs.label
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      withdrawal = withdrawal_fixture()

      conn = put(conn, Routes.withdrawal_path(conn, :update, withdrawal), withdrawal: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("withdrawals", "edit")
    end
  end

  describe "delete withdrawal" do

    test "deletes chosen withdrwl", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      withdrawal = withdrawal_fixture()

      conn = delete(conn, Routes.withdrawal_path(conn, :delete, withdrawal.id))
      assert redirected_to(conn) == Routes.withdrawal_path(conn, :index_account, withdrawal.account_id)

      assert_error_sent 404, fn ->
        get(conn, Routes.withdrawal_path(conn, :show, withdrawal.id))
      end
    end
  end

end
