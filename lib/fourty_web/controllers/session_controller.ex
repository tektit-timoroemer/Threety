defmodule FourtyWeb.SessionController do
  use FourtyWeb, :controller

  alias Fourty.{Users, Users.Guardian}
  alias Gettext
  
  plug Ueberauth
    
  # show home page - depending on login status

  def index(conn, _params) do
    render(conn, "index.html", current_user: get_session(conn, :current_user))
  end

  # show authentication dialogue

  def request(conn, _params) do
    changeset = Users.change_session(%Users.Login{},%{})
    maybe_user = Guardian.Plug.current_resource(conn)
    if maybe_user do
      redirect(conn, to: "/")
    else
      render(conn, "login.html", changeset: changeset, 
        path: Ueberauth.Strategy.Helpers.callback_url(conn)) 
    end
  end

  # process logout request

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> Guardian.log_out()
    |> put_flash(:info, dgettext("sessions", "logged_out"))
    |> redirect(to: "/")
  end

  # find the user account if it exists

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Users.find_user(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, dgettext("sessions", "authentication_success"))
        |> Guardian.log_in(user)
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, reason} when is_atom(reason) ->
        conn
        |> put_flash(:error,
           Gettext.dgettext(FourtyWeb.Gettext, "sessions", Atom.to_string(reason)))
        |> redirect(to: "/")
    end
  end

  # something went wrong ...

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, dgettext("sessions", "authentication_failed"))
    |> redirect(to: "/")
  end

  def callback(%{assigns: _else} = conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, "invalid callback")
  end

end