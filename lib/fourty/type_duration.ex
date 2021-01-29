defmodule Fourty.TypeDuration do
	use Ecto.Type
	def type, do: :integer

	@doc """
	Provides a type for models which allows durations to be processed:
	Since the database shall store durations as integer/minutes,
	casting must permit values formatted as durations, i.e. hh:mm,
	:mm, or hh.

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
  :error

  iex> cast("")
  {:ok, 0}
	"""
	def cast(cur) when is_binary(cur) do
		# does it look like a currency number?
		if Regex.match?(~r/^\s*\d*(\:[0-5]\d?)?\s*\z/, cur) do
			# yes! remove all blanks
			s = String.replace(cur, ~r/\s/, "")
			# if it contains no decimal point, add one
			s = unless(String.contains?(s, ":"), do: s <> ":00", else: s)
			[msp,lsp] = String.split(s, ":")
			msp = String.pad_leading(msp, 1, "0")
			lsp = String.pad_trailing(lsp, 2, "0")
			{:ok, String.to_integer(msp) * 60 + String.to_integer(lsp)}
		else
			:error
		end

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