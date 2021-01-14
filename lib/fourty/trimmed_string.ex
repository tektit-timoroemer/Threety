defmodule Fourty.TrimmedString do
  use Ecto.Type
  def type, do: :string

  @doc """
  Provides a type for models which causes whitespace characters at the
  start and the end of a string to be trimmed as well as multiple
  whitespace characters replaced by a single whitespace.

  Examples:
  
  iex> cast("  John Doe   ")
  {:ok, "John Doe"}

  iex> cast("John    Doe")
  {:ok, "John Doe"}

  iex> cast(1)
  :error
  """
  def cast(str) when is_binary(str) do
    clean_string =
      str
      |> String.trim()
      |> String.replace(~r/\s+/, " ")

    {:ok, clean_string}
  end

  def cast(_) do
    :error
  end

  def dump(str) do
    cast(str)
  end

  def load(str) when is_binary(str) do
    {:ok, str}
  end
end