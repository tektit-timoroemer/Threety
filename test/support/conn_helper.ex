defmodule FourtyWeb.ConnHelper do

  @endpoint FourtyWeb.Endpoint
  @password "test123TEST."

  def setup_user() do
    user =
      %Fourty.Users.User{}
      |> Fourty.Users.User.changeset(%{
        "username" => "user",
        "email" =>"test.user@e.mail",
        "password" => @password,
        "password_confirmation" => @password
      })
      |> Fourty.Repo.insert!()
    {:ok, user: user}
  end

  def setup_admin() do
    user =
      %Fourty.Users.User{}
      |> Fourty.Users.User.changeset(%{
        "role" => "1",
        "username" => "admin",
        "email" =>"test.admin@e.mail",
        "password" => @password,
        "password_confirmation" => @password
      })
      |> Fourty.Repo.insert!()
    {:ok, user: user}
  end

  require Phoenix.ConnTest

  def login_user(conn, username) do
    conn
    |> Phoenix.ConnTest.post(
        FourtyWeb.Router.Helpers.session_path(conn, :callback, :identity),
        account: %{username: username, password_plain: @password})
    |> Phoenix.ConnTest.get(
        FourtyWeb.Router.Helpers.session_path(conn, :index))

  end

  def get_user_pw(), do: @password
  
end