defmodule Fourty.TypeDuration do
  use Ecto.Type

  @doc """
  Provides a type for models which allows durations to be processed:
  Since the database shall store durations as integer/minutes,
  casting must permit values formatted as durations, i.e. hh:mm,
  :mm, or hh.

  This type is also used for time of day specifications because we do
  not need the extra precision.

  ## Examples

  iex> cast("  :01")
  {:ok, 1}

  iex> cast(":1  ")
  {:ok, 10}

  iex> cast("1")
  {:ok, 60}

  iex> cast("1:10")
  {:ok, 70}

   iex> cast("10:45")
   {:ok, 645}

   iex> cast("10:61")
   :error

   iex> cast("1:2")
   {:ok, 80}

   iex> cast(1.23)
   :error

   iex> cast(1)
   {:ok, 1}

   iex> cast("")
   {:ok, 0}
  """
  def cast(cur) when is_binary(cur) do
    # does it look like a duration?
    if Regex.match?(~r/^\s*\d*(\:[0-5]\d?)?\s*\z/, cur) do
      # yes! remove all blanks
      s = String.replace(cur, ~r/\s/, "")
      # if it contains no hour-minutes separator, add one
      s = unless(String.contains?(s, ":"), do: s <> ":00", else: s)
      [msp, lsp] = String.split(s, ":")
      msp = String.pad_leading(msp, 1, "0")
      lsp = String.pad_trailing(lsp, 2, "0")
      {:ok, String.to_integer(msp) * 60 + String.to_integer(lsp)}
    else
      :error
    end
  end

  def cast(int) when is_integer(int) do
    {:ok, int}
  end

  def cast(_) do
    :error
  end

  def dump(str) do
    cast(str)
  end

  def load(%Decimal{} = dec) do
    load(Decimal.to_integer(dec))
  end

  def load(int) when is_integer(int) do
    {:ok, int}
  end

  def type, do: :integer

  # format integer to hh:mm for display in views

  def min2dur(nil), do: ""
  def min2dur(%Decimal{} = dec), do: min2dur(Decimal.to_integer(dec))
  def min2dur(str) when is_binary(str), do: str

  def min2dur(value) when is_integer(value) do
    sign = if value < 0, do: "-", else: ""
    v = abs(value)
    r = rem(v, 60)

    sign <>
      Integer.to_string(trunc(v / 60)) <>
      ":" <>
      String.pad_leading(Integer.to_string(r), 2, "0")
  end
  
end
