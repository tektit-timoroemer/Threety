defmodule Fourty.TypeCurrency do
	use Ecto.Type

	@doc """
	Provides a type for models which allows currency values to be
	processed: Since the database shall store currency values as integers
	of the smallest unit (i.e. pennies for dollars, cents for Euros),
	casting must permit values formatted as currency.

	## Examples

	iex> cast("  .01")
	{:ok, 1}

	iex> cast(".1  ")
	{:ok, 10}

	iex> cast("1")
	{:ok, 100}

	iex> cast("1.1")
	{:ok, 110}

  iex> cast("12 345.67")
  {:ok, 1234567}

  iex> cast("12345.678")
  :error

  iex> cast("1.23 $")
  :error

  iex> cast("$ 1.23")
  :error

  iex> cast(1.23)
  :error

  iex> cast(1)
  {:ok, 1}

  iex> cast("")
  :error
	"""
	def cast(cur) when is_binary(cur) do
		# remove any leading and trailing blanks
		s = String.trim(cur)
		# does it look like a currency number?
		if Regex.match?(~r/^\d{1,3}(\s?\d\d\d)*(\.\d{0,2})?\z|^\.\d{1,2}\z/, s) do
			# yes! remove all blanks
			s = String.replace(s, ~r/\s/, "")
			# if it contains no decimal point, add one
			s = unless(String.contains?(s, "."), do: s <> ".", else: s)
			[msp,lsp] = String.split(s, ".")
			msp = String.pad_leading(msp, 1, "0")
			lsp = String.pad_trailing(lsp, 2, "0")
			{:ok, String.to_integer(msp) * 100 + String.to_integer(lsp)}
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

	def load(int) when is_integer(int) do
		{:ok, int}
	end

	def type, do: :integer

end