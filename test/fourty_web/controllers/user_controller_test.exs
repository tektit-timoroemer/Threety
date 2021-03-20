defmodule FourtyWeb.UserControllerTest do
  use FourtyWeb.ConnCase

  alias Fourty.Users
  alias FourtyWeb.ConnHelper
  import FourtyWeb.Gettext, only: [dgettext: 2]

  @good_password "test1234TEST."
  @bad_password1 "?" 

  @create_attrs %{username: "some name",
    password: "test1234TEST!", password_confirmation: "test1234TEST!",
    rate: 142, role: 1, email: "some.test@test.test"}
  @update_attrs %{username: "some updated name",
    rate: 143, role: 0, email: "other.test@test.test"}
  @invalid_attrs %{username: nil, rate: nil, role: nil, email: nil, 
    password: @bad_password1, password_confirmation: @bad_password1}

  def fixture(:user) do
    {:ok, user} = Users.create_user(@create_attrs)
    user
  end

  describe "index - admin only" do
    setup [:create_user]

    test "lists all users", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("users", "index")
    end

    test "redirects to homepage when no admin is signed in", %{conn: conn} do
      ConnHelper.setup_user()
      conn = ConnHelper.login_user(conn, "user")
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
    end

    test "redirects to homepage when not signed in", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
    end
  end

  describe "new user - admin only" do

    test "renders form for admin only", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ dgettext("users", "new")
    end

    test "new user redirects to homepage user is signed in", %{conn: conn} do
      ConnHelper.setup_user()
      conn = ConnHelper.login_user(conn, "user")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 302) =~ "redirected"
    end

    test "new user redirects to homepage when not signed in", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 302) =~ "redirected"
    end

  end

  describe "create user - admin only" do

    test "redirects to show when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      assert html_response(conn, 200) =~ dgettext("users", "show")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      resp = html_response(conn, 200)
      assert resp =~  dgettext("errors", "error_alert")
      assert html_response(conn, 200) =~ dgettext("users", "new")
    end

    test "create redirects to homepage when user is signed in", %{conn: conn} do
      ConnHelper.setup_user()
      conn = ConnHelper.login_user(conn, "user")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
    end

    test "create redirects to homepage when not signed in", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
    end
  end

  describe "edit user - admin only" do
    setup [:create_user]

    test "renders edit form for editing chosen user - admin only", %{conn: conn, user: user} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ dgettext("users", "edit")
    end

    test "edit redirects to homepage when user is signed in", %{conn: conn, user: user} do
      ConnHelper.setup_user()
      conn = ConnHelper.login_user(conn, "user")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 302) =~ "redirected"
    end

    test "edit redirects to homepage when not signed in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 302) =~ "redirected"
    end

  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid - admin only", %{conn: conn, user: user} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "redirects to homepage when user is signed in", %{conn: conn, user: user} do
      ConnHelper.setup_user()
      conn = ConnHelper.login_user(conn, "user")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
    end

    test "redirects to homepage when not signed in", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
    end

    test "renders errors when data is invalid - admin only", %{conn: conn, user: user} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("users", "edit")
    end
  end

  describe "each user may change her password when logged in" do
 
    test "renders edit pw form for changing password - admin", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = get(conn, Routes.user_path(conn, :edit_pw))
      assert html_response(conn, 200) =~ dgettext("sessions", "edit_pw")
    end

    test "renders edit pw form for changing password - user", %{conn: conn} do
      ConnHelper.setup_user()
      conn = ConnHelper.login_user(conn, "user")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = get(conn, Routes.user_path(conn, :edit_pw))
      assert html_response(conn, 200) =~ dgettext("sessions", "edit_pw")
    end

    test "edit pw redirects to homepage when not signed in", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :edit_pw))
      assert html_response(conn, 302) =~ "redirected"
    end

  end

  describe "perform password change when logged in" do
    
    test "change pw redirects to homepage when data are valid - admin", %{conn: conn} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = put(conn, Routes.user_path(conn, :update_pw),
        user: %{password_old: @bad_password1,
                password: @good_password,
                password_confirmation: @good_password})
      resp = html_response(conn, 200)
      assert resp =~ dgettext("errors", "error_alert")
      assert resp =~ dgettext("sessions", "edit_pw")

      conn = put(conn, Routes.user_path(conn, :update_pw),
        user: %{password_old: ConnHelper.get_user_pw(),
                password: @bad_password1,
                password_confirmation: @bad_password1})
      resp = html_response(conn, 200)
      assert resp =~ dgettext("errors", "error_alert")
      assert resp =~ dgettext("sessions", "edit_pw")

      conn = put(conn, Routes.user_path(conn, :update_pw),
        user: %{password_old: ConnHelper.get_user_pw(),
                password: @good_password,
                password_confirmation: @good_password})
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      conn = get(conn, Routes.user_path(conn, :index))
      assert get_flash(conn, :info) == dgettext("users", "pw_update_success")
    end

    test "change pw redirects to homepage when data are valid - user", %{conn: conn} do
      ConnHelper.setup_user()
      conn = ConnHelper.login_user(conn, "user")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = put(conn, Routes.user_path(conn, :update_pw),
        user: %{password_old: @bad_password1,
                password: @good_password,
                password_confirmation: @good_password})
      resp = html_response(conn, 200)
      assert resp =~ dgettext("errors", "error_alert")
      assert resp =~ dgettext("sessions", "edit_pw")

      conn = put(conn, Routes.user_path(conn, :update_pw),
        user: %{password_old: ConnHelper.get_user_pw(),
                password: @bad_password1,
                password_confirmation: @bad_password1})
      resp = html_response(conn, 200)
      assert resp =~ dgettext("errors", "error_alert")
      assert resp =~ dgettext("sessions", "edit_pw")

      conn = put(conn, Routes.user_path(conn, :update_pw),
        user: %{password_old: ConnHelper.get_user_pw(),
                password: @good_password,
                password_confirmation: @good_password})
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      conn = get(conn, Routes.user_path(conn, :index))
      assert get_flash(conn, :info) == dgettext("users", "pw_update_success")
    end

    test "change pw redirects to homepage when not logged in", %{conn: conn} do
      conn = put(conn, Routes.user_path(conn, :update_pw),
        user: %{password_old: @bad_password1,
                password: @good_password,
                password_confirmation: @good_password})
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)

      conn = put(conn, Routes.user_path(conn, :update_pw),
        user: %{password_old: ConnHelper.get_user_pw(),
                password: @bad_password1,
                password_confirmation: @bad_password1})
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)

      conn = put(conn, Routes.user_path(conn, :update_pw),
        user: %{password_old: ConnHelper.get_user_pw(),
                password: @good_password,
                password_confirmation: @good_password})
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user - admin only", %{conn: conn, user: user} do
      ConnHelper.setup_admin()
      conn = ConnHelper.login_user(conn, "admin")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)
    end

    test "must not delete chose user - user logged in", %{conn: conn, user: user} do
      ConnHelper.setup_user()
      conn = ConnHelper.login_user(conn, "user")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")

      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
    end

    test "must not delete chose user - none logged in", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
    end

  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
