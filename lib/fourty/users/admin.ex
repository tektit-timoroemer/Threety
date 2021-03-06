defmodule Fourty.Users.AdminOnly do
	use FourtyWeb, :controller

	def init(options), do: options

  def call(conn, _options) do
  	if Fourty.Users.has_role?(get_session(conn, :current_user), :admin) do
  		conn
  	else
	    conn
  	  |> put_flash(:error, dgettext("sessions", "insufficient_access_rights"))
    	|> redirect(to: Routes.session_path(conn, :index))
    	|> halt()
  	end
  end

end
