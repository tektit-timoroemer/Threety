defmodule Fourty.Users.Guardian do
  @moduledoc """
  Implementation module for Guardian and functions for authentication.
  """
  use Guardian, otp_app: :fourty

  # based on: Getting Started with Guardian

  alias Fourty.Users

  # Encodes the id of the user resource into the token

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  # Receives the decoded token as an argument and uses the user id
  # to load the resource from the database

  def resource_from_claims(%{"sub" => id}) do
    user = Users.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
  
  # Add the current resource to the connection in the Guardian-
  # configured location. Second, it adds the token to the session
  # to indicate the account has logged in

  def log_in(conn, user) do
    __MODULE__.Plug.sign_in(conn, user)
  end

  def log_out(conn) do
    __MODULE__.Plug.sign_out(conn)
  end

end
