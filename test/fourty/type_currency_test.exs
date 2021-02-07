defmodule Fourty.TypeCurrencyTest do
  use ExUnit.Case
  import Fourty.TypeCurrency
  doctest Fourty.TypeCurrency

  describe "tests for TypeCurrency" do
  	alias Fourty.TypeCurrency
  	
  	test "type should output the name of the db type" do
  		assert TypeCurrency.type == :integer
  	end

  	test "cast should receive string and return amount" do
  		assert TypeCurrency.cast("15000") == {:ok, 1500000}
  	end

  	test "load converts from db type to internal type" do
  		assert TypeCurrency.load(1500000) == {:ok, 1500000}
  	end

  	test "dump converts from internal type to db type" do
  		assert TypeCurrency.dump(1500000) == {:ok, 1500000}
		end

		test "it can build a changeset" do
			changeset = Ecto.Changeset.cast(%Fourty.Clients.Order{},
				%{amount_cur: "15000"}, [:amount_cur])
			assert changeset.valid?
		end

  end
end