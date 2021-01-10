defmodule FourtyWeb.ClientControllerTest do
  use FourtyWeb.ConnCase
  import FourtyWeb.Gettext, only: [dgettext: 2]
  alias Fourty.Clients

  @create_attrs %{date_end: ~D[2010-04-17], date_start: ~D[2010-04-17], name: "some name"}
  @update_attrs %{date_end: ~D[2011-05-18], date_start: ~D[2011-05-18], name: "some updated name"}
  @invalid_attrs %{date_end: nil, date_start: nil, name: nil}

  def fixture(:client) do
    {:ok, client} = Clients.create_client(@create_attrs)
    client
  end

  describe "index" do
    test "lists all clients", %{conn: conn} do
      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("clients","current clients")
    end
  end

  describe "new client" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.client_path(conn, :new))
      assert html_response(conn, 200) =~ dgettext("clients", "add client")
    end
  end

  describe "create client" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.client_path(conn, :create), client: @create_attrs)

      #assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.client_path(conn, :index)

      conn = get(conn, Routes.client_path(conn, :index))
      assert html_response(conn, 200) =~ dgettext("clients","current clients")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.client_path(conn, :create), client: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("clients","add client")
    end
  end

  describe "edit client" do
    setup [:create_client]

    test "renders form for editing chosen client", %{conn: conn, client: client} do
      conn = get(conn, Routes.client_path(conn, :edit, client))
      assert html_response(conn, 200) =~ dgettext("clients","edit client")
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
      assert html_response(conn, 200) =~ dgettext("clients","edit client")
    end
  end

  describe "delete client" do
    setup [:create_client]

    test "deletes chosen client", %{conn: conn, client: client} do
      conn = delete(conn, Routes.client_path(conn, :delete, client))
      assert redirected_to(conn) == Routes.client_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.client_path(conn, :index))
      end
    end
  end

  defp create_client(_) do
    client = fixture(:client)
    %{client: client}
  end
end
