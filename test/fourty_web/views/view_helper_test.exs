defmodule Fourty.ViewHelperTest do
  use ExUnit.Case
  use Phoenix.HTML
  import FourtyWeb.ViewHelpers
  import FourtyWeb.Gettext

  defp project_form_fixture() do
    Fourty.Clients.Project.changeset(
      %Fourty.Clients.Project{},
      %{name: "TEST NAME", date_start: ~D[2010-04-17], visible: true}
    )
    |> Map.replace(:action, :insert)
    |> form_for(%Plug.Conn{})
  end

  describe "test icon buttons" do
    test "my_icon_action" do
      icon_action = safe_to_string my_icon_action("calendar-minus", "/")
      assert icon_action =~ "/assets/static/icons/calendar-minus.svg"
      assert icon_action =~ "btn btn-sm btn-primary"
      assert icon_action =~ dgettext("global", "calendar-minus")
    end
  end

  describe "test duration conversion" do
    test "min2dur" do
      assert min2dur(nil) == ""
      assert min2dur(1) == "0:01"
      assert min2dur(9) == "0:09"
      assert min2dur(10) == "0:10"
      assert min2dur(59) == "0:59"
      assert min2dur(60) == "1:00"
      assert min2dur(599) == "9:59"
      assert min2dur(600) == "10:00"
      assert min2dur(601) == "10:01"
    end
  end

  describe "test currency conversion" do
    test "int2cur with positive numbers" do
      assert int2cur(nil) == ""
      assert int2cur(1) == "0.01"
      assert int2cur(99) == "0.99"
      assert int2cur(100) == "1.00"
      assert int2cur(101) == "1.01"
      assert int2cur(111) == "1.11"
      assert int2cur(123_456_789) == "1 234 567.89"
    end

    test "int2cur with negative numbers" do
      assert int2cur(-1) == "-0.01"
      assert int2cur(-99) == "-0.99"
      assert int2cur(-100) == "-1.00"
      assert int2cur(-101) == "-1.01"
      assert int2cur(-111) == "-1.11"
      assert int2cur(-123_456_789) == "-1 234 567.89"
    end
  end

  describe "my_label provides input field labels" do
    test "my_label for forms" do
      f = project_form_fixture()

      # required field: name

      l = safe_to_string(my_label(f, "projects", :name))
      t = dgettext("projects", "name")
      assert l == "<label class=\"form-label\" for=\"project_name\">#{t} *</label>"

      # optional field: visible

      l = safe_to_string(my_label(f, "projects", :visible))
      t = dgettext("projects", "visible")
      assert l == "<label class=\"form-label\" for=\"project_visible\">#{t}</label>"
    end

    test "my_label for show" do
      l = safe_to_string(my_label("global", "actions"))
      assert l == "<label class=\"form-label\">Actions</label>"
    end
  end

  describe "my_text_input/_value provides text fields" do
    test "my_text_value" do
      l = safe_to_string(my_text_value("TEST 123"))

      assert l ==
               ~s'<input class="form-control" type="text" ' <>
                 ~s'value="TEST 123" disabled readonly>'
    end

    test "my_text_input" do
      f = project_form_fixture()

      # required field :name

      l = safe_to_string(my_text_input(f, :name))

      assert l ==
               ~s'<input class="form-control is-valid" ' <>
                 ~s'id="project_name" name="project[name]" type="text" ' <>
                 ~s'value="TEST NAME" required>'

      # optional field: visible

      l = safe_to_string(my_text_input(f, :visible))

      assert l ==
               ~s'<input class="form-control is-valid" ' <>
                 ~s'id="project_visible" name="project[visible]" ' <>
                 ~s'type="text" value="true">'

      # field with errors

      l = safe_to_string(my_text_input(f, :client_id))

      assert l ==
               ~s'<input class="form-control is-invalid" ' <>
                 ~s'id="project_client_id" name="project[client_id]" ' <>
                 ~s'type="text" required>'
    end

    test "my_text_link creates text field with link" do
      l = safe_to_string(my_text_link("go here", "https://test.com"))

      assert l ==
               ~s'<div class="d-grid gap-2">' <>
                 ~s'<a class="text-start btn btn-outline-primary" ' <>
                 ~s'href="https://test.com" role="button">go here</a></div>'
    end

    test "my_longtext_input" do
      f = project_form_fixture()

      # required field :name

      l = safe_to_string(my_longtext_input(f, :name))

      assert l ==
               ~s'<textarea class="form-control is-valid" ' <>
                 ~s'id="project_name" name="project[name]" required>' <>
                 ~s'\nTEST NAME</textarea>'

      # optional field: visible

      l = safe_to_string(my_longtext_input(f, :visible))

      assert l ==
               ~s'<textarea class="form-control is-valid" ' <>
                 ~s'id="project_visible" name="project[visible]">' <>
                 ~s'\ntrue</textarea>'

      # field with errors

      l = safe_to_string(my_longtext_input(f, :client_id))

      assert l ==
               ~s'<textarea class="form-control is-invalid" ' <>
                 ~s'id="project_client_id" name="project[client_id]" required>' <>
                 ~s'\n</textarea>'
    end

    test "my_longtext_value" do
      l = safe_to_string(my_longtext_value("Test 123"))

      assert l ==
               ~s'<textarea class="form-control" disabled readonly>' <>
                 ~s'Test 123</textarea>'
    end

    test "my_checkbox_input" do
      f = project_form_fixture()
      l = safe_to_string(my_checkbox_input(f, :visible))

      assert l ==
               ~s'<input name="project[visible]" type="hidden" ' <>
                 ~s'value="false"><input class="form-check-input is-valid" ' <>
                 ~s'id="project_visible" name="project[visible]" ' <>
                 ~s'type="checkbox" value="true" checked>'
    end

    test "my_checkbox_value" do
      l = safe_to_string(my_checkbox_value(true))

      assert l ==
               ~s'<input class="form-check-input" type="checkbox" ' <>
                 ~s'checked disabled readonly>'
    end
  end
end
