defmodule Fourty.Users.Pipeline do
  @claims %{"typ" => "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :fourty,
    error_handler: FourtyWeb.ErrorHandler,
    module: Fourty.Users.Guardian

  # based on: Getting Started with Guardian

  # If there is a session token, restrict it to an access token and
  # validate it

  plug Guardian.Plug.VerifySession, claims: @claims

  # If there is an authorization header, restrict it to an access
  # token and validate it

  plug Guardian.Plug.VerifyHeader, claims: @claims

  # Load the user if either of the verifications worked
  
  plug Guardian.Plug.LoadResource, allow_blank: true

end