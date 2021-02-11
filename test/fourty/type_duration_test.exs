defmodule Fourty.TypeDurationTest do
  use ExUnit.Case
  import Fourty.TypeDuration
  doctest Fourty.TypeDuration

	describe "tests for TypeDuration" do
  	alias Fourty.TypeDuration
  	
  	test "type should output the name of the db type" do
  		assert TypeDuration.type == :integer
  	end

  	test "cast should receive string and return amount" do
  		assert TypeDuration.cast("1:45") == {:ok, 105}
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
			changeset = Ecto.Changeset.cast(%Fourty.Clients.Order{},
				%{amount_dur: "1:45"}, [:amount_dur])
			assert changeset.valid?
		end
	end
end