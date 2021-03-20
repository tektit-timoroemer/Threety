defmodule Fourty.ValidationTest do
  use ExUnit.Case

  # these tests are based on existing schemas - 

  describe "test validate_time_sequence" do
    alias Fourty.Costs.WorkItem
    @work_item_init %WorkItem{account_id: "1", user_id: "1", date_as_of: ~D[2021-03-20]}
    test "start time > end time" do
      t = 
        @work_item_init
        |> WorkItem.changeset(%{time_from: "00:01", time_to: "00:00"})
      refute t.valid?
      assert Keyword.has_key?(t.errors, :time_from)
      assert Keyword.has_key?(t.errors, :time_to)
    end    
  end

  describe "test duration_does_not_match_time" do
    alias Fourty.Costs.WorkItem
    @work_item_init %WorkItem{account_id: "1", user_id: "1", date_as_of: ~D[2021-03-20]}
    test "correct case" do
      t =
        @work_item_init
        |> WorkItem.changeset(%{duration: ":10", time_from: "00:00", time_to: "00:10"})
      assert t.valid?
    end
    test "difference less than duration" do
      t =
        @work_item_init
        |> WorkItem.changeset(%{duration: ":10", time_from: "00:01", time_to: "00:10"})
      refute t.valid?
      assert Keyword.has_key?(t.errors, :duration)
    end
    test "difference more than duration" do
      t =
        @work_item_init
        |> WorkItem.changeset(%{duration: ":10", time_from: "00:00", time_to: "00:11"})
      refute t.valid?
      assert Keyword.has_key?(t.errors, :duration)
    end
  end

  describe "test validate_time_of_day" do
    alias Fourty.Costs.WorkItem
    @work_item_init %WorkItem{account_id: "1", user_id: "1", date_as_of: ~D[2021-03-20]}
    test "empty/nil" do
      t =
        @work_item_init
        |> WorkItem.changeset(%{duration: ":01"})
      assert t.valid?
    end
    test "valid time 00:00-01:00" do
      t = 
        @work_item_init
        |> WorkItem.changeset(%{time_from: "0", time_to: "1"})
      assert t.valid?
    end
    test "invalid time 1" do
      t = 
        @work_item_init
        |> WorkItem.changeset(%{time_from: "-1", time_to: "24:00"})
      refute t.valid?
      assert Keyword.has_key?(t.errors, :time_from)
      refute Keyword.has_key?(t.errors, :time_to)
    end
    test "invalid time 2" do
      t =
        @work_item_init
        |> WorkItem.changeset(%{time_from: "0", time_to: "24:01"})
      refute t.valid?
      refute Keyword.has_key?(t.errors, :time_from)
      assert Keyword.has_key?(t.errors, :time_to)
    end
  end


  describe "at least one" do
    alias Fourty.Accounting.Deposit
    @deposit_init %Deposit{account_id: "1", order_id: "1"}
    test "standard case - two fields" do
      c =
        @deposit_init
        |> Deposit.changeset(%{description: "test", amount_cur: "1", amount_dur: "2"})

      assert c.valid?
    end

    test "standard case - first field" do
      c =
        @deposit_init
        |> Deposit.changeset(%{description: "test", amount_cur: "1"})

      assert c.valid?
    end

    test "standard case - second field" do
      c =
        @deposit_init
        |> Deposit.changeset(%{description: "test", amount_dur: "2"})

      assert c.valid?
    end

    test "error case - none" do
      c =
        @deposit_init
        |> Deposit.changeset(%{description: "test"})

      refute c.valid?
      assert Keyword.has_key?(c.errors, :amount_cur)
      assert Keyword.has_key?(c.errors, :amount_dur)
    end
  end

  describe "first date before or on second date" do
    alias Fourty.Accounting.Account

    test "standard OK case, date_start before date_end" do
      c =
        %Account{}
        |> Account.changeset(%{
          project_id: "1",
          name: "test",
          date_start: ~D[2010-04-17],
          date_end: ~D[2010-04-18]
        })

      assert c.valid?
    end

    test "standard OK case, date_start on date_end" do
      c =
        %Account{}
        |> Account.changeset(%{
          project_id: "1",
          name: "test",
          date_start: ~D[2010-04-18],
          date_end: ~D[2010-04-18]
        })

      assert c.valid?
    end

    test "error case, date_start after date_end" do
      c =
        %Account{}
        |> Account.changeset(%{
          project_id: "1",
          name: "test",
          date_start: ~D[2010-04-19],
          date_end: ~D[2010-04-18]
        })

      refute c.valid?
    end

    test "ignore, if none given" do
      c =
        %Account{}
        |> Account.changeset(%{project_id: "1", name: "test"})

      assert c.valid?
    end

    test "ignore if date_start not given" do
      c =
        %Account{}
        |> Account.changeset(%{project_id: "1", name: "test", date_end: ~D[2010-04-18]})

      assert c.valid?
    end

    test "ignore if date_end not given" do
      c =
        %Account{}
        |> Account.changeset(%{project_id: "1", name: "test", date_start: ~D[2010-04-18]})

      assert c.valid?
    end
  end
end
