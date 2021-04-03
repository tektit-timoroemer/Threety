defmodule FourtyWeb.WorkItemControllerTest do
  use FourtyWeb.ConnCase

  alias FourtyWeb.ConnHelper
  import FourtyWeb.Gettext
  import Fourty.Setup

    @create_attrs %{duration: 10, date_as_of: "today", user_id: 0}
    @update_attrs %{duration: 20}

    @today ~D[2021-03-25]
    @tomorrow ~D[2021-03-26]

    @valid_attrs %{
      comments: "some comments",
      date_as_of: @today,
      time_from: "14:00",
      time_to: "14:01",
    }
    @update_attrs %{
      comments: "some updated comments",
      date_as_of: @tomorrow,
      duration: 2,
      time_from: "15:00",
      time_to: "15:02",
    }
    @invalid_attrs %{
      comments: nil,
      date_as_of: nil,
      duration: nil,
      time_from: nil,
      time_to: nil,
    }

    @min_user_attrs %{
      username: "me",
      email: "me@test.test",
      rate: 100
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
      user_label = dgettext("work_items", "my")

      conn = get(conn0, Routes.work_item_path(conn0, :index_date, "2021-03-25"))
      assert html_response(conn, 200) =~ 
        dgettext("work_items", "index_date", %{user: user_label,
          date: dgettext("global", "weekday4") <> ", " <> to_string(@today)})

      conn = get(conn0, Routes.work_item_path(conn0, :index_date, "today"))
      assert html_response(conn, 200) =~ 
        dgettext("work_items", "index_date", %{user: user_label,
        date: dgettext("global","today")})
    end

    test "new - renders form for user himself", %{conn: conn} do
      ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")

      conn = get(conn0, Routes.work_item_path(conn0, :new, to_string(@today)))
      assert html_response(conn, 200) =~ dgettext("work_items", "new")
    end

    test "create redirects to show when data is valid", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_user()
      conn0 = ConnHelper.login_user(conn, "user")
      attrs = Map.merge(@valid_attrs, 
        %{user_id: user.id, account_id: account_fixture()})

      conn = post(conn0, Routes.work_item_path(conn0, :create), 
        work_item: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.work_item_path(conn, :show, id)

      conn = get(conn, Routes.work_item_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Work item"
    end
  end

  describe "test access - admin user" do
    
    test "lists all work_items for current admin user and date", %{conn: conn} do
      ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      user_label = dgettext("work_items", "my")

      conn = get(conn0, Routes.work_item_path(conn0, :index_date, "2021-03-25"))
      assert html_response(conn, 200) =~ 
        dgettext("work_items", "index_date", %{user: user_label,
          date: dgettext("global", "weekday4") <> ", " <> to_string(@today)})

      conn = get(conn0, Routes.work_item_path(conn0, :index_date, "today"))
      assert html_response(conn, 200) =~ 
        dgettext("work_items", "index_date", %{user: user_label,
        date: dgettext("global","today")})
    end

    test "new - renders form for admin user", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_user()
      {:ok, [user: admin]} = ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")

      # for calling admin

      conn = get(conn0, Routes.work_item_path(conn0, :new, to_string(@today)))
      assert html_response(conn, 200) =~ dgettext("work_items", "new")

      conn = get(conn0, Routes.work_item_user_path(conn0, :new, admin.id, to_string(@today)))
      assert html_response(conn, 200) =~ dgettext("work_items", "new")

      # for other user

      conn = get(conn0, Routes.work_item_user_path(conn0, :new, user.id, to_string(@today)))
      assert html_response(conn, 200) =~ dgettext("work_items", "new")
    end

   test "redirects to show when data is valid", %{conn: conn} do
      {:ok, [user: user]} = ConnHelper.setup_user()
      {:ok, [user: admin]} = ConnHelper.setup_admin()
      conn0 = ConnHelper.login_user(conn, "admin")
      attrs = Map.merge(@valid_attrs, 
        %{user_id: user.id, account_id: account_fixture()})

      # for calling admin

      conn = post(conn0, Routes.work_item_path(conn, :create), work_item: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.work_item_path(conn, :show, id)

      conn = get(conn, Routes.work_item_path(conn, :show, id))
      assert html_response(conn, 200) =~ dgettext("work_items", "show")
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
      assert redirected_to(conn) == Routes.work_item_path(conn, :index_date, work_item.user_id, to_string(work_item.date_as_of))

      assert_error_sent 404, fn ->
        get(conn, Routes.work_item_path(conn, :show, work_item))
      end
    end
  end

  defp create_work_item(_) do
    work_item = work_item_fixture()
    %{work_item: work_item}
  end
end
