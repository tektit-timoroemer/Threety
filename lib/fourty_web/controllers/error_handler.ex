defmodule FourtyWeb.Controllers.ErrorHandler do
  use FourtyWeb, :controller
  import FourtyWeb.Gettext, only: [dgettext: 3]
  
  # based on: Getting Started with Guardian

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_flash(:error, dgettext("errors","authentication", type: to_string(type)))
    |> redirect(to: Routes.session_path(conn, :request, :identity))
  end

end
