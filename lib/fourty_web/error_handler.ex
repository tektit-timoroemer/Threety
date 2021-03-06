defmodule FourtyWeb.ErrorHandler do
	import Plug.Conn
	use FourtyWeb, :controller

	# authentication error handler

	@behaviour Guardian.Plug.ErrorHandler

	@impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_flash(:error, dgettext("sessions", "authentication_error", type: Atom.to_string(type)))
    |> redirect(to: Routes.session_path(conn, :index))
  end

end
