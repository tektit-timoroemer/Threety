defmodule Fourty.TypeCurrencyTest do
  use ExUnit.Case
  import Fourty.TypeCurrency
  doctest Fourty.TypeCurrency

  describe "tests for TypeCurrency" do
    alias Fourty.TypeCurrency

    test "type should output the name of the db type" do
      assert TypeCurrency.type() == :integer
    end

    test "cast should receive string and return amount" do
      assert TypeCurrency.cast("15000") == {:ok, 1_500_000}
      assert TypeCurrency.cast("0.20") == {:ok, 20}
      assert TypeCurrency.cast(".20") == {:ok, 20}
      assert TypeCurrency.cast("20") == {:ok, 2000}
    end

    test "cast should receive integer and return amount" do
      assert TypeCurrency.cast(1_500_000) == {:ok, 1_500_000}
    end

    test "load converts from db type to internal type" do
      assert TypeCurrency.load(1_500_000) == {:ok, 1_500_000}
      assert TypeCurrency.load(Decimal.new(12345)) == {:ok, 12345}
    end

    test "dump converts from internal type to db type" do
      assert TypeCurrency.dump(1_500_000) == {:ok, 1_500_000}
    end

    test "it can build a changeset" do
      changeset =
        Ecto.Changeset.cast(%Fourty.Clients.Order{}, %{amount_cur: "15000"}, [:amount_cur])

      assert changeset.valid?
    end
  end
end
