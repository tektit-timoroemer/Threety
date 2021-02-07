defmodule Fourty.ViewHelperTest do
	use ExUnit.Case
	import FourtyWeb.ViewHelpers

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

	describe "test currency conversion" do
		
		test "int2cur with positive numbers" do
			assert int2cur(nil) == ""
			assert int2cur(1) == "0.01"
			assert int2cur(99) == "0.99"
			assert int2cur(100) == "1.00"
			assert int2cur(101) == "1.01"
			assert int2cur(111) == "1.11"
			assert int2cur(123456789) == "1 234 567.89"
		end

		test "int2cur with negative numbers" do
			assert int2cur(-1) == "-0.01"
			assert int2cur(-99) == "-0.99"
			assert int2cur(-100) == "-1.00"
			assert int2cur(-101) == "-1.01"
			assert int2cur(-111) == "-1.11"
			assert int2cur(-123456789) == "-1 234 567.89"
		end

	end

end
