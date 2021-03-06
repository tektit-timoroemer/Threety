defmodule Fourty.Validations do
  import Ecto.Changeset

  # Ensures that date1 comes before date2 or is equal to date2

  @validate_date_sequence_msg "first date must not be after second date"
  def validate_date_sequence(changeset, date1, date2) do
    d1 = get_field(changeset, date1)
    d2 = get_field(changeset, date2)

    case d1 && d2 && Date.compare(d1, d2) do
      :gt ->
        changeset
        |> add_error(date1, @validate_date_sequence_msg)
        |> add_error(date2, @validate_date_sequence_msg)

      _ ->
        changeset
    end
  end

  # Ensures that at least one of the given fields is provided

  @validate_at_least_one_msg "at least one must be given"
  def validate_at_least_one(changeset, fields) when is_list(fields) do
    Enum.map(fields, &get_field(changeset, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.empty?()
    |> if(do: add_errors(changeset, fields), else: changeset)
  end

  # recursively add error message for all fields in list

  defp add_errors(changeset, [head | tail]) do
    if Enum.empty?(tail) do
      add_error(changeset, head, @validate_at_least_one_msg)
    else
      add_errors(changeset, tail)
      |> add_error(head, @validate_at_least_one_msg)
    end
  end

  @validate_time_of_day_msg "time must be between 0:00 and 23:59"
  def validate_time_of_day(changeset, field) do
    if field <= 0 or field >= 1440,
      do: add_error(changeset, field, @validate_time_of_day_msg),
      else: changeset
  end

  # common password validation

  def validate_password(changeset, password) do
    validate_format(changeset, password,
     ~r/^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!.@#\$%\^&-+=\(\)])(?=\S+$).{8,}$/)
  end

end
