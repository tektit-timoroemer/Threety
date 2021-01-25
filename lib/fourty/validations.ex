defmodule Fourty.Validations do
	import Ecto.Changeset

	# Ensures that date1 comes before date2 or is equal to date2

	@validate_date_sequence_msg "first date must not be after second date"
	def validate_date_sequence(changeset, date1, date2) do
		d1 = get_field(changeset, date1)
		d2 = get_field(changeset, date2)

		cond do
			d1 && d2 && d1 > d2 ->
				changeset
				|> add_error(date1, @validate_date_sequence_msg)
				|> add_error(date2, @validate_date_sequence_msg)
			true ->
				changeset
		end
  end

end