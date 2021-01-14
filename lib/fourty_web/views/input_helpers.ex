defmodule FourtyWeb.InputHelpers do
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

  @doc """
  Replacement for label in forms
  * use gettext for label
  * append '*' to label when field is required
  """
  @spec my_label(struct(), String.t(), atom()) :: struct()
  def my_label(form, domain, field) do
    l = Gettext.dgettext(FourtyWeb.Gettext, domain, Atom.to_string(field))
    l = if required?(form, field), do: l <> " *"
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
  * inject class="format control" + "is-valid" pr "is-invalid"
  """
  @spec my_text_input(struct(), atom(), keyword(String.t())) :: struct()
  def my_text_input(form, field, options \\ []) do
    o = options ++ [class: "form-control " <> (if with_errors?(form, field), do: "is-invalid", else: "is-valid")]
    o = if required?(form, field), do: o ++ [required: "required"]
    text_input(form, field, o)
  end

  @doc """
  Replacement for text_input in show views so they look like forms
  """
  @spec my_text_value(String.t(), keyword(String.t())) :: struct()
  def my_text_value(value, options \\ []) do
    tag(:input, options ++ [type: "text", value: value, class: "form-control",
      readonly: "readonly", disabled: "disabled"])
  end

  @doc """
  Replacement for a back button
  """
  def my_back_link(path) do
    link(Gettext.dgettext(FourtyWeb.Gettext, "global", "back"), to: path, class: "btn btn-sm btn-outline-secondary", role: "button")
  end

  @doc """
  Replacement for action button
  """
  def my_action(domain, action, path) do
    link(Gettext.dgettext(FourtyWeb.Gettext, domain, action), to: path, class: "btn btn-sm btn-primary", role: "button") 
  end

  @doc """
  Replacement for submit button
  """
  def my_submit() do
    submit(Gettext.dgettext(FourtyWeb.Gettext, "global", "save"), class: "btn btn-sm btn-primary", role: "button")
  end

  def my_action_link(action, path) do
    l = Gettext.dgettext(FourtyWeb.Gettext, "global", action)
    if action == "delete" do
      link(l, to: path, method: :delete, data: [confirm: Gettext.dgettext(FourtyWeb.Gettext, "global", "sure?")])
    else
      link(l, to: path)
    end
  end

end
