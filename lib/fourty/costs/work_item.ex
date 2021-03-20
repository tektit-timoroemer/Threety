defmodule Fourty.Costs.WorkItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "work_items" do
    field :account_id, :integer, virtual: true
    field :comments, :string
    field :date_as_of, :date
    field :duration, Fourty.TypeDuration
    field :time_from, Fourty.TypeDuration
    field :time_to, Fourty.TypeDuration
    field :sequence, :integer, default: 0
    has_one :withdrwl, Fourty.Accounting.Withdrwl
    belongs_to :user, Fourty.Users.User
    timestamps()
  end

  @doc false
  def changeset(work_item, attrs) do
    work_item
    |> cast(attrs, [
      :account_id,
      :date_as_of,
      :duration,
      :time_from,
      :time_to,
      :comments,
      :user_id
    ])
    |> validate_required([:date_as_of, :user_id, :account_id])
    |> validate_number(:duration, greater_than: 0)
    |> Fourty.Validations.validate_time_of_day(:time_from)
    |> Fourty.Validations.validate_time_of_day(:time_to)
    |> validate_time_sequence(:time_from, :time_to)
    |> validate_combination(:duration, :time_from, :time_to)
    |> validate_duration_time(:duration, :time_from, :time_to)
  end

  @validate_time_sequence_msg "time_sequence_error_"
  defp validate_time_sequence(changeset, time_start, time_end) do
    s = get_field(changeset, time_start)
    e = get_field(changeset, time_end)

    if (s && e) do
      if (s < e) do
        changeset
      else
        add_error(changeset, time_start, @validate_time_sequence_msg <> "start")
        |> add_error(time_end, @validate_time_sequence_msg <> "end")
      end
    else
      changeset
    end    
  end


  @validate_duration_time_msg "duration_does_not_match_time"
  defp validate_duration_time(changeset, duration, time_start, time_end) do
    d = get_field(changeset, duration)
    s = get_field(changeset, time_start)
    e = get_field(changeset, time_end)

    if d && s && e do # all values must be given
      if d == (e - s) do # duration matches computed duration?
        changeset 
      else
        add_error(changeset, duration, @validate_duration_time_msg)
      end
    else
      changeset
    end    

  end

  @validate_combination_msg "bad_duration_time_combination"
  defp validate_combination(changeset, duration, time_start, time_end) do
    d = get_field(changeset, duration)
    s = get_field(changeset, time_start)
    e = get_field(changeset, time_end)
    c = changeset

    unless d || (s && e) do
      c =
        unless(d,
          do: add_error(c, duration, @validate_combination_msg),
          else: c
        )

      c =
        unless(s,
          do: add_error(c, time_start, @validate_combination_msg),
          else: c
        )

#     c =
        unless(e,
          do: add_error(c, time_end, @validate_combination_msg),
          else: c
        )
    else
      c
    end

  end

end
