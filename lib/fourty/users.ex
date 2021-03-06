defmodule Fourty.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  import FourtyWeb.Gettext
  alias Fourty.Repo
  alias Fourty.Users.User
  alias Fourty.Users.Login
  alias Ueberauth.Auth

  @doc """
  At this time, there are only two roles available to app users:
  > admin - with access to all features of the app (value: 1)
  > users (default) - only with access to work items (value: 0)
  When this scheme is modified, check all related methods below.
  """
  def list_roles_for_select() do
    [
      [key: dgettext("users","role_user"), value: 0],
      [key: dgettext("users","role_admin"), value: 1]
    ]
  end
  @doc """
  Retrieves label for the given role
  """
  def label_for_role(value) do
    Enum.find_value(list_roles_for_select(), "",
      fn [key: k, value: v] -> if(v == value, do: k) end)
  end
  @doc """
  Determines if given user has given role
  """
  def has_role?(user, :admin), do: user.role == 1
  def has_role?(user, :user), do: user.role == 0

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    from(u in User, order_by: u.username)
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Find user with the given credentials in %Ueberauth.Auth{}
  and set information.
  """
  def find_user(%Auth{provider: :identity} = auth) do
    %{"password_plain" => password, "username" => username} =
      Map.get(auth.extra.raw_info, "account")
    q = from u in User, where: u.username == ^username
    case Repo.one(q) do
      nil ->
        Argon2.no_user_verify()
        {:error, :authentication_failed}
      user ->
        if Argon2.verify_pass(password, user.password_encrypted) do
          {:ok, user}
        else
          {:error, :authentication_failed}
        end
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias Fourty.Users.Login

  def change_session(%Login{} = login, attrs \\ %{}) do
    Login.changeset(login, attrs)
  end

end
