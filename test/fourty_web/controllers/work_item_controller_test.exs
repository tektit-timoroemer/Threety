defmodule FourtyWeb.WorkItemControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  alias Phoenix.HTML
  import FourtyWeb.Gettext
  import Fourty.Setup

    @today ~D[2021-03-25]
    @tomorrow ~D[2021-03-26]

    @create_attrs %{
      label: "some label",
      date_as_of: @today,
      duration: 1,
      time_from: "14:00",
      time_to: "14:01",
    }
    @update_attrs %{
      label: "some updated label",
      date_as_of: @tomorrow,
      duration: 2,
      time_from: "15:00",
      time_to: "15:02",
    }
    @invalid_attrs %{
      label: nil,
      date_as_of: nil,
      duration: nil,
      time_from: nil,
      time_to: nil,
    }

  describe "test access" do
    setup [:create_work_item]

    test "non-existing user", %{conn: conn, work_item: work_item} do
      user_id = work_item.user_id
      date_as_of = "today"
      attrs = @create_attrs

      conn = get(conn, Routes.work_item_path(conn, :index_date, date_as_of))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.work_item_path(conn, :flip, date_as_of, 1, 2))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.work_item_path(conn, :new, date_as_of))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.work_item_path(conn, :delete, work_item))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.work_item_path(conn, :update, work_item),
        work_item: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.work_item_path(conn, :update, work_item),
        work_item: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = post(conn, Routes.work_item_path(conn, :create), work_item: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.work_item_path(conn, :show, work_item))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.work_item_path(conn, :edit, work_item))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")


      conn = get(conn, Routes.work_item_user_path(conn, :edit, user_id, work_item))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.work_item_user_path(conn, :show, user_id, work_item))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = post(conn, Routes.work_item_user_path(conn, :create, user_id), work_item: attrs)
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = put(conn, Routes.work_item_user_path(conn, :update, user_id, work_item))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = delete(conn, Routes.work_item_user_path(conn, :delete, user_id, work_item))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.work_item_user_path(conn, :new, user_id, date_as_of))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.work_item_user_path(conn, :flip, user_id, date_as_of, 1, 2))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")

      conn = get(conn, Routes.work_item_user_path(conn, :index_date, user_id, date_as_of))
      assert html_response(conn, 302) =~ "redirected"
      assert redirected_to(conn) == ConnHelper.homepage_path(conn)
      assert get_flash(conn, :error) == dgettext("sessions", "no_authentication")
    end
  end

  describe "test access - non-admin users" do

    test "lists all work_items for current normal user and date", %{conn: conn} do
      ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")

      conn = get(conn0, Routes.work_item_path(conn0, :index_date, "2021-03-25"))
      assert html_response(conn, 200) =~ 
        dgettext("work_items", "my_index_date",
          %{date: dgettext("global", "weekday4") <> ", " <> to_string(@today)})

      conn = get(conn0, Routes.work_item_path(conn0, :index_date, "today"))
      assert html_response(conn, 200) =~ 
        dgettext("work_items", "my_index_today")
    end

    test "flip - exchange position of work_item", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")
      w1 = work_item_fixture(%{user_id: user.id})
      w2 = work_item_fixture(%{user_id: user.id})
      assert w1.date_as_of == w2.date_as_of
      assert w1.sequence == 1
      assert w2.sequence == 2

      conn = get(conn0, Routes.work_item_path(
        conn0, :flip, to_string(w1.date_as_of), 1, 2))
      assert redirected_to(conn) == Routes.work_item_path(
        conn, :index_date, to_string(w1.date_as_of))
    end

    test "new - renders form for user himself", %{conn: conn} do
      ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")
      account_fixture() # need account to add work items

      conn = get(conn0, Routes.work_item_path(conn0, :new, to_string(@today)))
      assert html_response(conn, 200) =~ dgettext("work_items", "new")
    end

    test "create redirects to show when data is valid", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")
      attrs = Map.merge(@create_attrs, 
        %{user_id: user.id, account_id: account_fixture().id})

      conn = post(conn0, Routes.work_item_path(conn0, :create), 
        work_item: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.work_item_path(conn, :show, id)

      conn = get(conn, Routes.work_item_path(conn, :show, id))
      assert html_response(conn, 200) =~ dgettext("work_items", "show")
    end

    test "renders form for editing chosen work_item", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")
      attrs = Map.merge(@create_attrs, 
        %{user_id: user.id, account_id: account_fixture().id})
      work_item = work_item_fixture(attrs)

      conn = get(conn0, Routes.work_item_path(conn0, :edit, work_item))
      assert html_response(conn, 200) =~ dgettext("work_items", "edit")
    end

    test "redirects when data is valid", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")
      attrs = Map.merge(@create_attrs, %{user_id: user.id})
      work_item = work_item_fixture(attrs)

      conn = put(conn0, Routes.work_item_path(conn0, :update, work_item.id),
        work_item: @update_attrs)
      assert redirected_to(conn) == Routes.work_item_path(conn, :show, work_item)

      conn = get(conn, Routes.work_item_path(conn, :show, work_item))
      assert html_response(conn, 200) =~ "some updated label"
    end

    test "renders errors when data are invalid", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")
      attrs = Map.merge(@create_attrs, %{user_id: user.id})
      work_item = work_item_fixture(attrs)

      conn = put(conn0, Routes.work_item_path(conn0, :update, work_item.id),
        work_item: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("work_items", "edit")
    end

    test "deletes work_item", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")
      attrs = Map.merge(@create_attrs, %{user_id: user.id})
      work_item = work_item_fixture(attrs)

      conn = delete(conn0, Routes.work_item_path(conn0, :delete, work_item.id))
      assert redirected_to(conn) == Routes.work_item_path(
        conn, :index_date, to_string(work_item.date_as_of))

      assert_error_sent 404, fn ->
        get(conn, Routes.work_item_path(conn, :show, work_item))
      end
    end

  end


  describe "test access - admin user for himself" do

    test "lists all work_items for current admin user and date", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")

      conn = get(conn0, Routes.work_item_path(conn0, :index_date, "2021-03-25"))
      assert html_response(conn, 200) =~ 
        dgettext("work_items", "my_index_date",
          %{date: dgettext("global", "weekday4") <> ", " <> to_string(@today)})

      conn = get(conn0, Routes.work_item_path(conn0, :index_date, "today"))
      assert html_response(conn, 200) =~ 
        dgettext("work_items", "my_index_today")
    end

    test "flip - exchange position of work_item", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      w1 = work_item_fixture(%{user_id: user.id})
      w2 = work_item_fixture(%{user_id: user.id})
      assert w1.date_as_of == w2.date_as_of
      assert w1.sequence == 1
      assert w2.sequence == 2

      conn = get(conn0, Routes.work_item_path(
        conn0, :flip, to_string(w1.date_as_of), 1, 2))
      assert redirected_to(conn) == Routes.work_item_path(
        conn, :index_date, to_string(w1.date_as_of))
    end

    test "new - renders form for user himself", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      account_fixture() # need account to add work items

      conn = get(conn0, Routes.work_item_path(conn0, :new, to_string(@today)))
      assert html_response(conn, 200) =~ dgettext("work_items", "new")
    end

    test "create redirects to show when data is valid", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      attrs = Map.merge(@create_attrs, 
        %{user_id: user.id, account_id: account_fixture().id})

      conn = post(conn0, Routes.work_item_path(conn0, :create), 
        work_item: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.work_item_path(conn, :show, id)

      conn = get(conn, Routes.work_item_path(conn, :show, id))
      assert html_response(conn, 200) =~ dgettext("work_items", "show")
    end

    test "renders form for editing chosen work_item", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      attrs = Map.merge(@create_attrs, 
        %{user_id: user.id, account_id: account_fixture().id})
      work_item = work_item_fixture(attrs)

      conn = get(conn0, Routes.work_item_path(conn0, :edit, work_item))
      assert html_response(conn, 200) =~ dgettext("work_items", "edit")
    end

    test "redirects when data is valid", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      attrs = Map.merge(@create_attrs, %{user_id: user.id})
      work_item = work_item_fixture(attrs)

      conn = put(conn0, Routes.work_item_path(conn0, :update, work_item.id),
        work_item: @update_attrs)
      assert redirected_to(conn) == Routes.work_item_path(conn, :show, work_item)

      conn = get(conn, Routes.work_item_path(conn, :show, work_item))
      assert html_response(conn, 200) =~ "some updated label"
    end

    test "renders errors when data are invalid", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      attrs = Map.merge(@create_attrs, %{user_id: user.id})
      work_item = work_item_fixture(attrs)

      conn = put(conn0, Routes.work_item_path(conn0, :update, work_item.id),
        work_item: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("work_items", "edit")
    end

    test "deletes work_item", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      attrs = Map.merge(@create_attrs, %{user_id: user.id})
      work_item = work_item_fixture(attrs)

      conn = delete(conn0, Routes.work_item_path(conn0, :delete, work_item.id))
      assert redirected_to(conn) == Routes.work_item_path(
        conn, :index_date, to_string(work_item.date_as_of))

      assert_error_sent 404, fn ->
        get(conn, Routes.work_item_path(conn, :show, work_item))
      end
    end

  end

  describe "access - admin user for other user" do
    
    test "lists all work_items for other user and date", %{conn: conn} do
      ConnHelper.setup_admin()
      {:ok, [user: user]} = ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "admin")

      conn = get(conn0, Routes.work_item_user_path(
        conn0, :index_date, user.id, to_string(@today)))
      assert html_response(conn, 200) =~ 
        HTML.safe_to_string(HTML.html_escape(
        dgettext("work_items", "others_index_date", %{name: user.username,
          date: dgettext("global", "weekday4") <> ", " <> to_string(@today)})))

      conn = get(conn0, Routes.work_item_user_path(
        conn0, :index_date, user.id, "today"))
      assert html_response(conn, 200) =~ 
        HTML.safe_to_string(HTML.html_escape(
        dgettext("work_items", "others_index_today", %{name: user.username})))
    end

    test "flip - exchange position of work_item", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      {:ok, [user: user]} = ConnHelper.setup_user()
      w1 = work_item_fixture(%{user_id: user.id})
      w2 = work_item_fixture(%{user_id: user.id})
      assert w1.date_as_of == w2.date_as_of
      assert w1.sequence == 1
      assert w2.sequence == 2

      conn = get(conn0, Routes.work_item_user_path(
        conn0, :flip, user.id, to_string(w1.date_as_of), 1, 2))
      assert redirected_to(conn) == Routes.work_item_user_path(
        conn, :index_date, user.id, to_string(w1.date_as_of))
    end

    test "new - renders form for other user", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      {:ok, [user: user]} = ConnHelper.setup_user()
      account_fixture() # need account to add work items

      conn = get(conn0, Routes.work_item_user_path(
        conn0, :new, user.id, to_string(@today)))
      assert html_response(conn, 200) =~ dgettext("work_items", "new")
    end

    test "create redirects to show when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      {:ok, [user: user]} = ConnHelper.setup_user()
      attrs = Map.merge(@create_attrs, 
        %{user_id: user.id, account_id: account_fixture().id})

      conn = post(conn0, Routes.work_item_user_path(
        conn0, :create, user.id), work_item: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) ==
        Routes.work_item_user_path(conn, :show, user.id, id)

      conn = get(conn, Routes.work_item_user_path(conn, :show, user.id, id))
      assert html_response(conn, 200) =~ dgettext("work_items", "show")
    end

    test "renders form for editing chosen work_item", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      {:ok, [user: user]} = ConnHelper.setup_user()
      attrs = Map.merge(@create_attrs, 
        %{user_id: user.id, account_id: account_fixture().id})
      work_item = work_item_fixture(attrs)

      conn = get(conn0, Routes.work_item_user_path(conn0, :edit, user.id, work_item))
      assert html_response(conn, 200) =~ dgettext("work_items", "edit")
    end

    test "redirects when data is valid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      {:ok, [user: user]} = ConnHelper.setup_user()
      attrs = Map.merge(@create_attrs, %{user_id: user.id})
      work_item = work_item_fixture(attrs)

      conn = put(conn0, Routes.work_item_user_path(
        conn0, :update, user.id, work_item.id), work_item: @update_attrs)
      assert redirected_to(conn) == Routes.work_item_user_path(
        conn, :show, user.id, work_item.id)

      conn = get(conn, Routes.work_item_user_path(
        conn, :show, user.id, work_item.id))
      assert html_response(conn, 200) =~ "some updated label"
    end

    test "renders errors when data are invalid", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      {:ok, [user: user]} = ConnHelper.setup_user()
      attrs = Map.merge(@create_attrs, %{user_id: user.id})
      work_item = work_item_fixture(attrs)

      conn = put(conn0, Routes.work_item_user_path(
        conn0, :update, user.id, work_item.id), work_item: @invalid_attrs)
      assert html_response(conn, 200) =~ dgettext("work_items", "edit")
    end

    test "deletes work_item", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      {:ok, [user: user]} = ConnHelper.setup_user()
      attrs = Map.merge(@create_attrs, %{user_id: user.id})
      work_item = work_item_fixture(attrs)

      conn = delete(conn0, Routes.work_item_user_path(
        conn0, :delete, user.id, work_item.id))
      assert redirected_to(conn) == Routes.work_item_user_path(
        conn, :index_date, user.id, to_string(work_item.date_as_of))

      assert_error_sent 404, fn ->
        get(conn, Routes.work_item_user_path(
          conn, :show, user.id, work_item.id))
      end
    end
  end

  defp create_work_item(_) do
    work_item = work_item_fixture()
    %{work_item: work_item}
  end
end
