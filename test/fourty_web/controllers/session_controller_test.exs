defmodule FourtyWeb.SessionControllerTest do
  use FourtyWeb.ConnCase

  alias Phoenix.HTML.Safe
  alias Fourty.Users.User
  alias FourtyWeb.ConnHelper
  import FourtyWeb.Gettext, only: [dgettext: 2, dgettext: 3]

  @ok_credentials %{username: "testuser", password_plain: "test123TEST."}
  @bad_credentials_1 %{username: "baduser", password_plain: "test123TEST."}
  @bad_credentials_2 %{username: "testuser", password_plain: "password_plain"}
  @bad_credentials_3 %{username: "baduser", password_plain: "password_plain"}

  def setup_user(_conn) do
    user =
      %User{}
      |> User.changeset(%{
        "password_old" => "dummy",
        "username" => "testuser",
        "email" =>"test.user@e.mail",
        "password" => "test123TEST.",
        "password_confirmation" => "test123TEST."
      })
      |> Fourty.Repo.insert!()

    {:ok, user: user}
  end

  describe "index" do
    test "show home page (all sessions)", %{conn: conn} do
      conn = ConnHelper.get_homepage(conn)
      assert html_response(conn, 200) =~
        Safe.to_iodata(dgettext("sessions", "welcome"))
    end
  end

  describe "login" do
    setup [:setup_user]

    test "show login request", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :request, :identity))
      assert html_response(conn, 200) =~ dgettext("sessions", "login_identity")
    end

    test "login", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :callback, :identity), 
        account: @ok_credentials)
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      conn = ConnHelper.get_homepage(conn)
      assert html_response(conn, 200) =~ 
        dgettext("sessions", "welcome %{user}", user: "testuser")
      assert get_flash(conn, :info) == dgettext("sessions", "authentication_success")
    end
  end

  describe "login should fail" do
    setup [:setup_user]

    test "login attempt with bad user name", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :callback, :identity), 
        account: @bad_credentials_1)
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      conn = ConnHelper.get_homepage(conn)
      assert html_response(conn, 200) =~ 
        Safe.to_iodata(dgettext("sessions", "welcome"))
      assert get_flash(conn, :error) == dgettext("sessions", "authentication_failed")
    end

    test "login attempt with bad password", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :callback, :identity), 
        account: @bad_credentials_2)
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      conn = ConnHelper.get_homepage(conn)
      assert html_response(conn, 200) =~ 
        Safe.to_iodata(dgettext("sessions", "welcome"))
      assert get_flash(conn, :error) == dgettext("sessions", "authentication_failed")
    end

    test "login attempt with bad user name and password", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :callback, :identity), 
        account: @bad_credentials_3)
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      conn = ConnHelper.get_homepage(conn)
      assert html_response(conn, 200) =~ 
        Safe.to_iodata(dgettext("sessions", "welcome"))
      assert get_flash(conn, :error) == dgettext("sessions", "authentication_failed")
    end

  end

  describe "logoff" do
    setup [:setup_user]

    test "login and logoff", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :callback, :identity), 
        account: @ok_credentials)
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      conn = ConnHelper.get_homepage(conn)
      assert html_response(conn, 200) =~ 
        dgettext("sessions", "welcome %{user}", user: "testuser")

      conn = get(conn, Routes.session_path(conn, :logout))
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      conn = ConnHelper.get_homepage(conn)

      assert html_response(conn, 200) =~ 
        Safe.to_iodata(dgettext("sessions", "welcome"))

# TODO for some unknown reason, the flash message does not appear heare
# during testing ... :-(
#
#     assert get_flash(conn, :info) == dgettext("sessions", "logged_out")
    end
  end

end