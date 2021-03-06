defmodule Fourty.UsersTest do
  use Fourty.DataCase

  alias Fourty.Users

  describe "users" do
    alias Fourty.Users.User

    @valid_attrs %{username: "some name",
      password: "topsecret", password_confirmation: "topsecret",
      rate: 142, role: 0, email: "test@test.test"}
    @update_attrs %{username: "some updated name",
      password: "newsecret", password_confirmation: "newsecret",
      rate: 143, role: 1, email: "other.test@test.test"}
    @invalid_attrs %{username: nil, rate: nil, role: nil, email: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_user()
      user
    end

    defp same_users?(u1, u2) do
      # returns true if both users are identical ignoring the
      # virtual fields
      Map.equal?(
        Map.drop(u1, [:password, :password_confirmation]),
        Map.drop(u2, [:password, :password_confirmation])
        )
    end

    test "list_users/0 returns all users" do
      u = user_fixture()
      l = Users.list_users()
      assert length(l) == 1
      assert same_users?(List.first(l), u)
    end

    test "get_user!/1 returns the user with given id" do
      u = user_fixture()
      assert same_users?(Users.get_user!(u.id), u)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = u} = Users.create_user(@valid_attrs)
      assert {:ok, u} == Argon2.check_pass(u, "topsecret", hash_key: :password_encrypted)
      assert u.username == "some name"
      assert u.rate == 142
      assert u.role == 0
      assert u.email == "test@test.test"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      u = user_fixture()
      assert {:ok, %User{} = u} = Users.update_user(u, @update_attrs)
      assert {:ok, u} == Argon2.check_pass(u, "newsecret", hash_key: :password_encrypted)
      assert u.username == "some updated name"
      assert u.rate == 143
      assert u.role == 1
      assert u.email == "other.test@test.test"
    end

    test "update_user/2 with invalid data returns error changeset" do
      u = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(u, @invalid_attrs)
      assert same_users?(u, Users.get_user!(u.id))
    end

    test "delete_user/1 deletes the user" do
      u = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(u)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(u.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end

  describe "sessions" do
    alias Fourty.Users.Session
  end

end
