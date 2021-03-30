defmodule Fourty.ViewHelperTest do
  use ExUnit.Case
  use Phoenix.HTML
  import FourtyWeb.ViewHelpers
  import FourtyWeb.Gettext

  defp project_form_fixture() do
    Fourty.Clients.Project.changeset(
      %Fourty.Clients.Project{},
      %{label: "TEST NAME", date_start: ~D[2010-04-17], visible: true}
    )
    |> Map.replace(:action, :insert)
    |> form_for(%Plug.Conn{})
  end

  describe "test icon buttons" do
    test "my_icon_action" do
      icon_action = safe_to_string my_icon_action("calendar-minus-fill", "/")
      assert icon_action =~ "/icons/calendar-minus-fill.svg"
      assert icon_action =~ "btn btn-sm btn-primary"
      assert icon_action =~ dgettext("global", "calendar-minus-fill")
    end
  end

  describe "my_label provides input field labels" do
    test "my_label for forms" do
      f = project_form_fixture()

      # required field: label

      l = safe_to_string(my_label(f, "projects", :label))
      t = dgettext("projects", "label")
      assert l == "<label class=\"form-label\" for=\"project_label\">#{t} *</label>"

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

      # required field :label

      l = safe_to_string(my_text_input(f, :label))

      assert l ==
               ~s'<input class="form-control is-valid" ' <>
                 ~s'id="project_label" label="project[label]" type="text" ' <>
                 ~s'value="TEST NAME" required>'

      # optional field: visible

      l = safe_to_string(my_text_input(f, :visible))

      assert l ==
               ~s'<input class="form-control is-valid" ' <>
                 ~s'id="project_visible" label="project[visible]" ' <>
                 ~s'type="text" value="true">'

      # field with errors

      l = safe_to_string(my_text_input(f, :client_id))

      assert l ==
               ~s'<input class="form-control is-invalid" ' <>
                 ~s'id="project_client_id" label="project[client_id]" ' <>
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

      # required field :label

      l = safe_to_string(my_longtext_input(f, :label))

      assert l ==
               ~s'<textarea class="form-control is-valid" ' <>
                 ~s'id="project_label" label="project[label]" required>' <>
                 ~s'\nTEST NAME</textarea>'

      # optional field: visible

      l = safe_to_string(my_longtext_input(f, :visible))

      assert l ==
               ~s'<textarea class="form-control is-valid" ' <>
                 ~s'id="project_visible" label="project[visible]">' <>
                 ~s'\ntrue</textarea>'

      # field with errors

      l = safe_to_string(my_longtext_input(f, :client_id))

      assert l ==
               ~s'<textarea class="form-control is-invalid" ' <>
                 ~s'id="project_client_id" label="project[client_id]" required>' <>
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
               ~s'<input label="project[visible]" type="hidden" ' <>
                 ~s'value="false"><input class="form-check-input is-valid" ' <>
                 ~s'id="project_visible" label="project[visible]" ' <>
                 ~s'type="checkbox" value="true" checked>'
    end

    test "my_checkbox_value" do
      l = safe_to_string(my_checkbox_value(true))

      assert l ==
               ~s'<input class="form-check-input" type="checkbox" ' <>
                 ~s'checked disabled readonly>'
    end
  end

  describe "miscellaneous functions" do

    test "delta" do
      assert delta(nil, nil) == nil
      assert delta(nil, 1) == nil
      assert delta(1, nil) == nil
      assert delta(1, 1) == 0
      assert delta(1, 2) == -1
      assert delta(2, 1) == 1
    end

    test "weekday" do
      assert weekday(~D[2021-03-01]) == dgettext("global", "weekday1")
      assert weekday(~D[2021-03-02]) == dgettext("global", "weekday2")
      assert weekday(~D[2021-03-03]) == dgettext("global", "weekday3")
      assert weekday(~D[2021-03-04]) == dgettext("global", "weekday4")
      assert weekday(~D[2021-03-05]) == dgettext("global", "weekday5")
      assert weekday(~D[2021-03-06]) == dgettext("global", "weekday6")
      assert weekday(~D[2021-03-07]) == dgettext("global", "weekday7")
    end

    test "date_with_weekday" do
      assert date_with_weekday(~D[2021-03-01]) == "Monday, 2021-03-01"
    end

  end
end
