defmodule FourtyWeb.ClientControllerTest do
  use FourtyWeb.ConnCase
  import FourtyWeb.Gettext, only: [dgettext: 2]
  alias Fourty.Clients

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:client) do
    {:ok, client} = Clients.create_client(@create_attrs)
    client
  end

  describe "index" do
    test "lists all clients", %{conn: conn} do
      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("clients","index")
    end
  end

  describe "show" do
    setup [:create_client]

    test "show data for a specific client", %{conn: conn, client: client} do
      conn = get(conn, Routes.client_path(conn, :show, client))
      assert html_response(conn, 200) =~ dgettext("clients", "show")
    end

    test "show non-existing client", %{conn: conn, client: client} do
      # this will fail due to get_client! failure
      c = Map.replace(client, :id, 0)
      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.client_path(conn, :show, c))
        end
    end

  end

  describe "new client" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.client_path(conn, :new))
      assert html_response(conn, 200) =~ dgettext("clients", "add")
    end
  end

  describe "create client" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.client_path(conn, :create), client: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.client_path(conn, :show, id)

      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("clients","index")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.client_path(conn, :create), client: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("clients","add")
    end
  end

  describe "edit client" do
    setup [:create_client]

    test "renders form for editing chosen client", %{conn: conn, client: client} do
      conn = get(conn, Routes.client_path(conn, :edit, client))
      assert html_response(conn, 200) =~ dgettext("clients","edit")
    end
  end

  describe "update client" do
    setup [:create_client]

    test "redirects when data is valid", %{conn: conn, client: client} do
      conn = put(conn, Routes.client_path(conn, :update, client), client: @update_attrs)
      assert redirected_to(conn) == Routes.client_path(conn, :index)

      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      conn = put(conn, Routes.client_path(conn, :update, client), client: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("clients","edit")
    end
  end

  describe "delete client" do
    setup [:create_client]

    test "deletes chosen client", %{conn: conn, client: client} do
      conn = delete(conn, Routes.client_path(conn, :delete, client))
      assert redirected_to(conn) == Routes.client_path(conn, :index)

      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("clients","index")
    end

    test "delete non-existing client", %{conn: conn, client: client} do
      # this will fail due to get_client! failure
      c = Map.replace(client, :id, 0)
      assert_raise Ecto.NoResultsError, fn ->
        delete(conn, Routes.client_path(conn, :delete, c))
        end
    end

  end

  defp create_client(_) do
    client = fixture(:client)
    %{client: client}
  end
end
