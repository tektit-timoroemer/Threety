defmodule Fourty.Costs.WorkItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "work_items" do
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
      :date_as_of,
      :duration,
      :time_from,
      :time_to,
      :comments,
      :user_id,
      :withdrwl_id,
      :sequence
    ])
    |> validate_required([:date_as_of, :user_id, :sequence])
    |> validate_combination(:duration, :time_from, :time_to)
    |> validate_number(:duration, greater_than: 0)
    |> Fourty.Validations.validate_time_of_day(:time_from)
    |> Fourty.Validations.validate_time_of_day(:time_to)
  end

  @validate_combination_msg "either duration or start and end must be given"
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
