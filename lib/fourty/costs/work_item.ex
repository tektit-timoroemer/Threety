defmodule Fourty.Costs.WorkItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "work_items" do
    field :account_id, :integer, virtual: true
    field :label, :string
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
      :label,
      :user_id
    ])
    |> validate_required([:date_as_of, :user_id, :account_id])
    |> validate_number(:duration, greater_than: 0)
    |> validate_time_of_day(:time_from)
    |> validate_time_of_day(:time_to)
    |> validate_time_sequence()
    |> validate_combination()
    |> validate_duration_time()
    |> assoc_constraint(:user)
  end

  # compute duration if not yet given unless changeset has errors

  def get_duration(changeset) do
    d = get_field(changeset, :duration)
    if changeset.valid? && is_nil(d) do
      get_field(changeset, :time_to) - get_field(changeset, :time_from)
    else
      d
    end
  end

  @validate_time_of_day_msg "time_format_error"
  defp validate_time_of_day(changeset, field) do
    f = get_field(changeset, field)
    if f && (f < 0 or f > 1440) do
      add_error(changeset, field, @validate_time_of_day_msg)
    else
      changeset
    end
  end

  @validate_time_sequence_msg "time_sequence_error_"
  defp validate_time_sequence(changeset) do
    f = get_field(changeset, :time_from)
    t = get_field(changeset, :time_to)

    if changeset.valid? && (f && t) do
      if (f < t) do
        changeset
      else
        add_error(changeset, :time_from, @validate_time_sequence_msg <> "start")
        |> add_error(:time_to, @validate_time_sequence_msg <> "end")
      end
    else
      changeset
    end    
  end

  @validate_duration_time_msg "duration_does_not_match_time"
  defp validate_duration_time(changeset) do
    d = get_field(changeset, :duration)
    f = get_field(changeset, :time_from)
    t = get_field(changeset, :time_to)

    if changeset.valid? && d && f && t do # all values must be given
      if d == (t - f) do # duration matches computed duration?
        changeset 
      else
        add_error(changeset, :duration, @validate_duration_time_msg)
      end
    else
      changeset
    end    

  end

  # The following implementation allows only to enter either a
  # duration or a start and end time. Alternatively, the following
  # scheme could be possible:
  # - define default duration (e.g. 10 min)
  # - define a granularity for the current time (e.g. round to 
  #   nearest 10 minute interval, e.g. at 12:04 -> 12:00, at 12:06
  #   -> 12:10, or always truncated to the nearest 10 minute 
  #   interval, i.e. at 12:09 -> 12:00, at 12:11 -> 12:10)
  # - missing values could be computed as follows:
  #   given (d - duration, f - from, t - to)
  #   dft : check if duration matches time range
  #   d__ : f = now, e = now + d
  #   df_ : e = f + d
  #   d_t : f = e - d
  #   _f_ : d = default, e = f - d
  #   _ft : d = t - f
  #   __t : d = default, f = t - d
  #   ___ : d = default, f = now, t = f + d

  @validate_combination_msg "bad_duration_time_combination"
  defp validate_combination(changeset) do
    d = get_field(changeset, :duration)
    f = get_field(changeset, :time_from)
    t = get_field(changeset, :time_to)
    c = changeset

    unless c.valid? && (d || (f && t)) do
      c =
        unless(d,
          do: add_error(c, :duration, @validate_combination_msg),
          else: c
        )

      c =
        unless(f,
          do: add_error(c, :time_from, @validate_combination_msg),
          else: c
        )

#     c =
        unless(t,
          do: add_error(c, :time_to, @validate_combination_msg),
          else: c
        )
    else
      c
    end

  end

end
