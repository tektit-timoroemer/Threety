defmodule Fourty.TrimmedString do
  use Ecto.Type
  def type, do: :string

  @doc """
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