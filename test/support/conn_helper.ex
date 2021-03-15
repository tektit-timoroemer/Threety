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

  def homepage_path(conn) do
    FourtyWeb.Router.Helpers.session_path(conn, :index)
  end

  def get_homepage(conn) do
    Phoenix.ConnTest.get(conn, homepage_path(conn))
  end
  
  def login_user(conn, username) do
    conn
    |> Phoenix.ConnTest.post(
        FourtyWeb.Router.Helpers.session_path(conn, :callback, :identity),
        account: %{username: username, password_plain: @password})
    |> get_homepage()

  end

  def get_user_pw(), do: @password

end