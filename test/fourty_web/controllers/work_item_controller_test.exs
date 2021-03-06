defmodule FourtyWeb.WorkItemControllerTest do
  use FourtyWeb.ConnCase

  alias Fourty.Costs

  @create_attrs %{
    account_id: 42,
    comments: "some comments",
    date_as_of: ~D[2010-04-17],
    duration: 42,
    order: 42,
    time_from: ~T[14:00:00],
    time_to: ~T[14:00:00],
    user_id: 42,
    withdrwl_id: 42
  }
  @update_attrs %{
    account_id: 43,
    comments: "some updated comments",
    date_as_of: ~D[2011-05-18],
    duration: 43,
    order: 43,
    time_from: ~T[15:01:01],
    time_to: ~T[15:01:01],
    user_id: 43,
    withdrwl_id: 43
  }
  @invalid_attrs %{
    account_id: nil,
    comments: nil,
    date_as_of: nil,
    duration: nil,
    order: nil,
    time_from: nil,
    time_to: nil,
    user_id: nil,
    withdrwl_id: nil
  }

  def fixture(:work_item) do
    {:ok, work_item} = Costs.create_work_item(@create_attrs)
    work_item
  end

  describe "index" do
    test "lists all work_items", %{conn: conn} do
      conn = get(conn, Routes.work_item_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Work items"
    end
  end

  describe "new work_item" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.work_item_path(conn, :new))
      assert html_response(conn, 200) =~ "New Work item"
    end
  end

  describe "create work_item" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.work_item_path(conn, :create), work_item: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.work_item_path(conn, :show, id)

      conn = get(conn, Routes.work_item_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Work item"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.work_item_path(conn, :create), work_item: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Work item"
    end
  end

  describe "edit work_item" do
    setup [:create_work_item]

    test "renders form for editing chosen work_item", %{conn: conn, work_item: work_item} do
      conn = get(conn, Routes.work_item_path(conn, :edit, work_item))
      assert html_response(conn, 200) =~ "Edit Work item"
    end
  end

  describe "update work_item" do
    setup [:create_work_item]

    test "redirects when data is valid", %{conn: conn, work_item: work_item} do
      conn = put(conn, Routes.work_item_path(conn, :update, work_item), work_item: @update_attrs)
      assert redirected_to(conn) == Routes.work_item_path(conn, :show, work_item)

      conn = get(conn, Routes.work_item_path(conn, :show, work_item))
      assert html_response(conn, 200) =~ "some updated comments"
    end

    test "renders errors when data is invalid", %{conn: conn, work_item: work_item} do
      conn = put(conn, Routes.work_item_path(conn, :update, work_item), work_item: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Work item"
    end
  end

  describe "delete work_item" do
    setup [:create_work_item]

    test "deletes chosen work_item", %{conn: conn, work_item: work_item} do
      conn = delete(conn, Routes.work_item_path(conn, :delete, work_item))
      assert redirected_to(conn) == Routes.work_item_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.work_item_path(conn, :show, work_item))
      end
    end
  end

  defp create_work_item(_) do
    work_item = fixture(:work_item)
    %{work_item: work_item}
  end
end
