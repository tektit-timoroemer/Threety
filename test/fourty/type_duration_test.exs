defmodule Fourty.TypeDurationTest do
  use ExUnit.Case
  import Fourty.TypeDuration
  doctest Fourty.TypeDuration

  describe "tests for TypeDuration" do
    alias Fourty.TypeDuration

    test "type should output the name of the db type" do
      assert TypeDuration.type() == :integer
    end

    test "cast should receive string and return amount" do
      assert TypeDuration.cast("1:45") == {:ok, 105}
      assert TypeDuration.cast("0:20") == {:ok, 20}
      assert TypeDuration.cast(":20") == {:ok, 20}
      assert TypeDuration.cast("20") == {:ok, 1200}
    end

    test "cast should receive integer and return amount" do
      assert TypeDuration.cast(105) == {:ok, 105}
    end

    test "load converts from db type to internal type" do
      assert TypeDuration.load(105) == {:ok, 105}
      assert TypeDuration.load(Decimal.new(12345)) == {:ok, 12345}
    end

    test "dump converts from internal type to db type" do
      assert TypeDuration.dump(105) == {:ok, 105}
    end

    test "it can build a changeset" do
      changeset =
        Ecto.Changeset.cast(%Fourty.Clients.Order{}, %{amount_dur: "1:45"}, [:amount_dur])

      assert changeset.valid?
    end
  end

  describe "test duration conversion" do
    test "min2dur" do
      assert min2dur(nil) == ""
      assert min2dur(1) == "0:01"
      assert min2dur(9) == "0:09"
      assert min2dur(10) == "0:10"
      assert min2dur(59) == "0:59"
      assert min2dur(60) == "1:00"
      assert min2dur(599) == "9:59"
      assert min2dur(600) == "10:00"
      assert min2dur(601) == "10:01"
    end
  end
   
end
