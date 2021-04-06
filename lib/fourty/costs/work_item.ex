defmodule Fourty.Costs.WorkItem do
  @moduledoc """

  The WorkItem schema extends the Withdrawal schema by additional
  information regarding current work items.

  Work Items belong to a specific user.

  A Work Item can only be removed if its duration is 0 minutes. This is
  in order to prohibit the invalidation of the accounting history.

  ## Fields

    - label: an optional field to remarks on the work item

    - date_as_of: the date for which the accounting information was
      created

    - duration: a duration of time; alternatively, the period time_from
      and time_to can be used. 

    - time_from, time_to: a time period; alternatively, the duration
      can be set using the field duration.

      All three fields - duration, time_from and time_to - can be set
      but the duration specified must match the duration given by the
      period from time_from until time_to.

    - sequence: is an internal field which is used to keep the records
      within a single day in a user-controllable order.

    - account_id: is the id of the account to which the Work Item is
      related to. This information is not saved to the database as the
      account association is kept in the related withdrawal record. In
      fact, the account_id is needed only to create or modify the Work
      Item. If the account_id is given, it must point to an existing
      account record.

  """
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
    has_one :withdrawal, Fourty.Accounting.Withdrawal
    has_one :account, through: [:withdrawal, :account]
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
    |> validate_number(:duration, greater_than_or_equal_to: 0)
    |> validate_time_of_day(:time_from)
    |> validate_time_of_day(:time_to)
    |> validate_time_sequence()
    |> validate_combination()
    |> validate_duration_time()
    |> assoc_constraint(:user)
    |> validate_account()
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

  # ensure that account is open for transactions on the date_as_of date
  # but check only if either date_as_of or account_id has changed ...

  @validate_account_msg "invalid_account"
  defp validate_account(changeset) do
    if changeset.valid? do
      d = get_field(changeset, :date_as_of)
      a = get_field(changeset, :account_id)
        |> Fourty.Accounting.get_account_solo!()
      unless Fourty.Accounting.account_open?(a, d) do
        add_error(changeset, :account_id, @validate_account_msg)
      else
        changeset    
      end
    else
      changeset
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
      if (f <= t) do
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
