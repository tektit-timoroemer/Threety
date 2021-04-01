defmodule Fourty.Accounting.Account do
  @moduledoc """

  The Account schema contains information about a specific account -
  similar to a bank account. An account shows deposits (when money or
  time is added to an account) and withdrawels (when money or time is
  removed from an account).

  Accounts can only be used for transactions in the period [date_start,
  date_end]. This permits to add accounts before allowing any
  transactions on the account. If further permits to close accounts for
  further transactions.

  An account can be made not visible in order to hide it from any
  reports. However, all accounts and transactions will be kept in the
  system until explicitly removed.

  An account always belongs to a single project but a project can have
  more than one account.

  ## Fields

    - label: the unique name or identifier of the account (this 
    corresponds to the account number of a bank account). Any leading 
    and trailing as well as duplicate whitespace characters will be
    removed before the label is stored in the system.

    - date_start: the date on which this account is open for
    transactions. The date_start date must occur before the date_end
    date.

    - date_end: the date when the account is closed for any further
    transactions. The date_end date must occur on or after the
    date_start date. When date_start equal to date_end, the account
    was effectively never open.

    - visible: when the flag is cleared, the account will not be shown
    in any reports and listings. Normally, you would first close an
    account and then clear this flag.

    - balance_cur: is an internally used field and holds the current
    balance (in currency units) during computations.

    - balance_dur: is an internally used field and holds the current
    balance (in time units) during computations.

  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :label, Fourty.TypeTrimmedString
    field :date_end, :date, default: nil
    field :date_start, :date, default: nil
    field :visible, :boolean, default: true
    field :balance_cur, Fourty.TypeCurrency, virtual: true, default: nil
    field :balance_dur, Fourty.TypeDuration, virtual: true, default: nil
    belongs_to :project, Fourty.Clients.Project
    has_many :withdrawals, Fourty.Accounting.Withdrawal
    has_many :deposits, Fourty.Accounting.Deposit
    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:label, :date_start, :date_end, :visible, :project_id])
    |> validate_required([:label, :project_id])
    |> Fourty.Validations.validate_date_sequence(:date_start, :date_end)
    |> assoc_constraint(:project)
    |> unique_constraint(:label, label: :accounts_project_id_label_index)
  end
end
