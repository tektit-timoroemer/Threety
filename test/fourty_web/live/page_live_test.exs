defmodule FourtyWeb.PageLiveTest do
  use FourtyWeb.ConnCase

  import Phoenix.LiveViewTest

  @tag :skip
  test "disconnected and connected render", %{conn: conn} do
  	{:error, :nosession} = live(conn, "/")

    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to Phoenix!"
    assert render(page_live) =~ "Welcome to Phoenix!"
  end
end
