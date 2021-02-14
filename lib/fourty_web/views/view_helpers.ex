defmodule FourtyWeb.ViewHelpers do
  @moduledoc """
  Input Helper for views to ensure consistent user interface
  """
  use Phoenix.HTML

  # the list of required fields can be found in form.source which
  # contains the underlying changeset
  @doc false
  defp required?(form, field) do 
    field in form.source.required
  end

  # a field has no errors if there was no action yet!
  @doc false
  defp with_errors?(form, field) do
    form.source.action && Keyword.has_key?(form.source.errors, field)
  end

  # mark required fields by adding " *" to given label
  @doc false
  defp mark_required(label, form, field) do
    if required?(form, field), do: label <> " *", else: label
  end

  # fix options list, options are appended with new values, 'required' 
  # overrides any previous setting
  @doc false
  @spec set_options(keyword(String.t()), struct(), atom()) :: keyword(String.t())
  defp set_options(form, field, class \\ "form-control", value \\ nil) do
    o = [class: class <> (if with_errors?(form, field), do: " is-invalid", else: " is-valid")]
    o = if required?(form, field), do: o ++ [required: true], else: o
    unless is_nil(value), do: o ++ [value: value], else: o
  end 

  # readonly_input, given options override defaults
  @doc false
  defp readonly_input(type, value, class \\ "form-control") do
    case type do
    :checkbox ->
      tag(:input, type: :checkbox, checked: value, class: "form-check-input",
        readonly: true, disabled: true)
    _ ->
      tag(:input, type: type, value: value, class: class,
        readonly: true, disabled: true)
    end
  end

  @doc """
  Replacement for label in forms
  * use gettext for label
  * append '*' to label when field is required
  """
  @spec my_label(struct(), String.t(), atom()) :: struct()
  def my_label(form, domain, field) do
    l = Gettext.dgettext(FourtyWeb.Gettext, domain, Atom.to_string(field))
    |> mark_required(form, field)
    label(form, field, l, class: "form-label")
  end

  @doc """
  Replacement for label in show views so they look like forms
  """
  @spec my_label(String.t(), String.t()) :: struct()
  def my_label(domain, field) do
    content_tag(
      :label,
      Gettext.dgettext(FourtyWeb.Gettext, domain, field),
      class: "form-label")
  end

  @doc """
  Replacement for text_input:
  * inject class="format control" + "is-valid" or "is-invalid"
  """
  @spec my_text_input(struct(), atom()) :: struct()
  def my_text_input(form, field) do
    text_input(form, field, set_options(form, field))
  end

  @doc """
  Replacement for text_input in show views so they look like forms
  """
  @spec my_text_value(String.t()) :: struct()
  def my_text_value(value) do
    readonly_input(:text, value)
  end

  def my_text_link(value, link) do
    content_tag(:div,
      link(value, to: link, class: "text-start btn btn-outline-primary",
        role: "button"), class: "d-grid gap-2")
  end

  def my_longtext_input(form, field) do
    textarea(form, field, set_options(form, field))
  end

  def my_longtext_value(value) do
    content_tag(:textarea, value, class: "form-control",
        readonly: true, disabled: true)
  end

  def my_checkbox_input(form, field) do
    checkbox(form, field, set_options(form, field, "form-check-input"))
  end

  def my_checkbox_value(value) do
    readonly_input(:checkbox, value)
  end

  @spec my_date_input(struct(), atom()) :: struct()
  def my_date_input(form, field) do
    date_input(form, field, set_options(form, field))
  end

  @spec my_date_value(String.t()) :: struct()
  def my_date_value(value) do
    readonly_input(:date_input, value)
  end

  # format date/time for display

  def my_date_time(value) do
    value
  end

  def my_currency_input(form, field) do
    text_input(form, field, set_options(form, field, "text-end form-control",
      int2cur(input_value(form, field))))
  end

  def my_currency_value(value) do
    readonly_input(:text, int2cur(value), "text-end form-control")
  end

  def my_duration_input(form, field) do
    text_input(form, field, set_options(form, field, "text-end form-control",
      min2dur(input_value(form, field))))
  end

  def my_duration_value(value) do
    readonly_input(:text, min2dur(value), "text-end form-control")
  end

  def my_select_input(form, field, selection) do
    select(form, field, selection, set_options(form, field))
  end

  # Replacement for a back button

  def my_back_link(path) do
    link(Gettext.dgettext(FourtyWeb.Gettext, "global", "back"), to: path, 
      class: "btn btn-sm btn-outline-secondary", role: "button")
  end

  # Replacement for action button

  def my_action(domain, "delete", path) do
    link(Gettext.dgettext(FourtyWeb.Gettext, domain, "delete"),
      to: path, class: "btn btn-sm btn-primary", role: "button",
      method: :delete, 
      data: [confirm: Gettext.dgettext(FourtyWeb.Gettext, "global","confirm")])
  end

  def my_action(domain, action, path) do
    link(Gettext.dgettext(FourtyWeb.Gettext, domain, action),
      to: path, class: "btn btn-sm btn-primary", role: "button") 
  end

  def my_action(domain, action, path, param) do
    link(Gettext.dgettext(FourtyWeb.Gettext, domain, action, param),
      to: path, class: "btn btn-sm btn-primary", role: "button") 
  end

  # Replacement for submit button

  def my_submit() do
    submit(Gettext.dgettext(FourtyWeb.Gettext, "global", "save"),
      class: "btn btn-sm btn-primary", role: "button")
  end

  def my_action_link(domain, action, path) do
    l = Gettext.dgettext(FourtyWeb.Gettext, domain, action)
    if action == "delete" do
      link(l, to: path, 
        method: :delete, 
        data: [confirm: Gettext.dgettext(FourtyWeb.Gettext, "global", "confirm")],
        class: "link-primary")
    else
      link(l, to: path, class: "link-primary")
    end
  end

  # helpers for calculations

  def delta(value1, value2) do
    value1 && value2 && (value1 - value2)
  end

  # format integer to hh:mm for display in views

  def min2dur(nil), do: ""
  def min2dur(%Decimal{} = dec), do: min2dur(Decimal.to_integer(dec))
  def min2dur(str) when is_binary(str), do: str
  def min2dur(value) when is_integer(value) do
    sign = if value < 0, do: "-", else: ""
    v = abs(value)
    r = rem(v, 60)
    sign <> Integer.to_string(trunc(v / 60)) <> ":" <>
      String.pad_leading(Integer.to_string(r), 2, "0")
  end

  # format integer to currency d ddd ... ddd.dd for display in views

  @thousands_separator " "
  @decimal_separator "."
 
  def int2cur(nil), do: ""
  def int2cur(%Decimal{} = dec), do: int2cur(Decimal.to_integer(dec))
  def int2cur(str) when is_binary(str), do: str
  def int2cur(value) when is_integer(value) do
    sign = if value < 0, do: "-", else: ""
    v = abs(value)
    ls = Integer.to_string(rem(v, 100))
    ms = Integer.to_string(trunc(v / 100))
    lm = String.length(ms)
    ms = String.graphemes(ms)
    {ms,_} = Enum.map_reduce(ms, lm, fn c, i ->
      { if(rem(i, 3) == 0, do: @thousands_separator <> c, else: c), i - 1 } end)
    sign <> Enum.join(ms) <> @decimal_separator <> String.pad_leading(ls, 2, "0")
  end

end
