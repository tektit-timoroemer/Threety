defmodule FourtyWeb.UserController do
  use FourtyWeb, :controller

  alias Fourty.Users
  alias Fourty.Users.User
  alias Fourty.Users.EditPW
 
  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Users.change_user(%User{})
    |> Ecto.Changeset.validate_required([:password, :password_confirmation])
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, dgettext("users", "create_success"))
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def edit_pw(conn, _params) do
    changeset = Users.change_edit_pw(%EditPW{})
    path = Routes.user_path(conn, :update_pw)
    render(conn, "edit_pw.html", changeset: changeset, path: path)    
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)
    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, dgettext("users", "update_success"))
        |> redirect(to: Routes.user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def update_pw(conn, %{"user" => user_params }) do
    user = get_session(conn, :current_user)
    pw_old = Map.get(user_params, "password_old")
    unless Argon2.verify_pass(pw_old, user.password_encrypted) do
      %Ecto.Changeset{}
      |> Ecto.Changeset.add_error(:password_old, "wrong_old_pw")
      |> Ecto.Changeset.apply_action(:update)
    else
      Users.update_user(user, user_params)
    end
    |> case do
      {:ok, _user} ->
      conn
        |> put_flash(:info, dgettext("users", "pw_update_success"))
        |> redirect(to: Routes.session_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        path = Routes.user_path(conn, :update_pw)
        render(conn, "edit_pw.html", changeset: changeset, path: path)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _user} = Users.delete_user(user)

    conn
    |> put_flash(:info, dgettext("users", "delete_success"))
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
