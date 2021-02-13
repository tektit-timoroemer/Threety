defmodule FourtyWeb.WithdrwlControllerTest do
  use FourtyWeb.ConnCase
  import FourtyWeb.Gettext, only: [dgettext: 2, dgettext: 3]
  alias Fourty.Accounting

  @create_attrs %{amount_cur: 42, amount_dur: 43, description: "a withdrawal"}
  @update_attrs %{amount_cur: 44, amount_dur: 45, description: "another withdrawal"}
  @invalid_attrs %{amount_cur: nil, amount_dur: nil, description: nil}

  def fixture(:withdrwl) do
    {:ok, withdrwl} = Accounting.create_withdrwl(@create_attrs)
    withdrwl
  end

  describe "index" do
    test "lists all withdrwls", %{conn: conn} do
      conn = get(conn, Routes.withdrwl_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Withdrwls"
    end
  end

  describe "new withdrwl" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.withdrwl_path(conn, :new))
      assert html_response(conn, 200) =~ "New Withdrwl"
    end
  end

  describe "create withdrwl" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.withdrwl_path(conn, :create), withdrwl: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.withdrwl_path(conn, :show, id)

      conn = get(conn, Routes.withdrwl_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Withdrwl"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.withdrwl_path(conn, :create), withdrwl: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Withdrwl"
    end
  end

  describe "edit withdrwl" do
    setup [:create_withdrwl]

    test "renders form for editing chosen withdrwl", %{conn: conn, withdrwl: withdrwl} do
      conn = get(conn, Routes.withdrwl_path(conn, :edit, withdrwl))
      assert html_response(conn, 200) =~ "Edit Withdrwl"
    end
  end

  describe "update withdrwl" do
    setup [:create_withdrwl]

    test "redirects when data is valid", %{conn: conn, withdrwl: withdrwl} do
      conn = put(conn, Routes.withdrwl_path(conn, :update, withdrwl), withdrwl: @update_attrs)
      assert redirected_to(conn) == Routes.withdrwl_path(conn, :show, withdrwl)

      conn = get(conn, Routes.withdrwl_path(conn, :show, withdrwl))
      assert html_response(conn, 200) =~ "some updated rate_cur_per_hour"
    end

    test "renders errors when data is invalid", %{conn: conn, withdrwl: withdrwl} do
      conn = put(conn, Routes.withdrwl_path(conn, :update, withdrwl), withdrwl: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Withdrwl"
    end
  end

  describe "delete withdrwl" do
    setup [:create_withdrwl]

    test "deletes chosen withdrwl", %{conn: conn, withdrwl: withdrwl} do
      conn = delete(conn, Routes.withdrwl_path(conn, :delete, withdrwl))
      assert redirected_to(conn) == Routes.withdrwl_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.withdrwl_path(conn, :show, withdrwl))
      end
    end
  end

  defp create_withdrwl(_) do
    withdrwl = fixture(:withdrwl)
    %{withdrwl: withdrwl}
  end
end
