defmodule FourtyWeb.AccountControllerTest do
  use FourtyWeb.ConnCase

  alias Fourty.Accounting

  @create_attrs %{visible: true,
    date_end: ~D[2010-04-17], date_start: ~D[2010-04-17], name: "some name"}
  @update_attrs %{
    date_end: ~D[2011-05-18], date_start: ~D[2011-05-18], name: "some updated name"}
  @invalid_attrs %{date_end: nil, date_start: nil, name: nil, visible: nil}

  def fixture(:client) do
    {:ok, client} = Fourty.Clients.create_client(%{name: "test client"})
    client
  end

  def fixture(:project) do
    {:ok, project} = Fourty.Clients.create_project(%{name: "test project", client_id: fixture(:client).id})   
    project
  end

  def fixture(:account) do
    attrs = Map.merge(@create_attrs, %{project_id: fixture(:project).id})
    {:ok, account} = Accounting.create_account(attrs)
    account
  end

  describe "index" do
    test "lists all accounts", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :index))
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts","index")
      assert html_response(conn, 200) =~ heading
    end
  end

  describe "new account" do
    test "renders form", %{conn: conn} do
      project = fixture(:project)
      conn = get(conn, Routes.account_path(conn, :new, project))
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts","add")
      assert html_response(conn, 200) =~ heading
    end
  end

  describe "create account" do
    test "redirects to show when data is valid", %{conn: conn} do
      project = fixture(:project)
      attrs = Map.merge(@create_attrs, %{client_id: project.client_id, project_id: project.id})
      conn = post(conn, Routes.account_path(conn, :create), account: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.account_path(conn, :show, id)

      conn = get(conn, Routes.account_path(conn, :show, id))
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts","show")
      assert html_response(conn, 200) =~ heading
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project = fixture(:project)
      attrs = Map.merge(@invalid_attrs, %{client_id: project.client_id, project_id: project.id})
      conn = post(conn, Routes.account_path(conn, :create), account: attrs)
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts","add")
      assert html_response(conn, 200) =~ heading
    end
  end

  describe "edit account" do
    setup [:create_account]

    test "renders form for editing chosen account", %{conn: conn, account: account} do
      conn = get(conn, Routes.account_path(conn, :edit, account))
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts","edit")
      assert html_response(conn, 200) =~ heading
    end
  end

  describe "update account" do
    setup [:create_account]

    test "redirects when data is valid", %{conn: conn, account: account} do
      conn = put(conn, Routes.account_path(conn, :update, account), account: @update_attrs)
      assert redirected_to(conn) == Routes.account_path(conn, :show, account)

      conn = get(conn, Routes.account_path(conn, :show, account))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      conn = put(conn, Routes.account_path(conn, :update, account), account: @invalid_attrs)
      heading = Gettext.dgettext(FourtyWeb.Gettext, "accounts","edit")
      assert html_response(conn, 200) =~ heading
    end
  end

  describe "delete account" do
    setup [:create_account]

    test "deletes chosen account", %{conn: conn, account: account} do
      conn = delete(conn, Routes.account_path(conn, :delete, account))
      assert redirected_to(conn) == Routes.account_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.account_path(conn, :show, account))
      end
    end
  end

  defp create_account(_) do
    account = fixture(:account)
    %{account: account}
  end
end
