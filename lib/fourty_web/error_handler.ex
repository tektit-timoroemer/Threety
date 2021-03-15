defmodule FourtyWeb.ErrorHandler do
	use FourtyWeb, :controller

	# authentication error handler

	@behaviour Guardian.Plug.ErrorHandler

	@impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    case type do
      :unauthenticated -> 
				put_flash(conn, :error, dgettext("sessions", "no_authentication"))
      _ ->
				put_flash(conn, :error, dgettext("sessions", "authentication_error",
					type: Atom.to_string(type)))
    end
    |> redirect(to: Routes.session_path(conn, :index))
  end

end
