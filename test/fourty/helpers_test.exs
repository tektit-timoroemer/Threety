defmodule Fourty.HelpersTest do
  use Fourty.DataCase

  alias Fourty.Helpers

  describe "clients" do

  	test "trim_item" do
  		m = %{
  			"zero" => "zero",
  			"one" => " one ",
  			"two" => "  two  ",
  			"none" => nil }
  		assert Helpers.trim_item(m, "zero") == m
  		assert Helpers.trim_item(m, "one") == Map.replace(m, "one", "one")
  		assert Helpers.trim_item(m, "two") == Map.replace(m, "two", "two")
  		assert Helpers.trim_item(m, "three") == m
  		assert Helpers.trim_item(m, "none") == m
  		assert Helpers.trim_item(m, "") == m
  		assert Helpers.trim_item(m, nil) == m
  	end

  	test "trim_items" do
  		m = %{
  			"zero" => "zero",
  			"one" => " one ",
  			"two" => "  two  ",
  			"none" => nil }
  		assert Helpers.trim_items(m, ["zero"]) == m
  		assert Helpers.trim_items(m, ["one"]) == Map.replace(m, "one", "one")
  		assert Helpers.trim_items(m, ["two"]) == Map.replace(m, "two", "two")
  		assert Helpers.trim_items(m, ["three"]) == m
  		assert Helpers.trim_items(m, ["none"]) == m
  		assert Helpers.trim_items(m, [""]) == m
  		assert Helpers.trim_items(m, [nil]) == m
  		assert Helpers.trim_items(m, ["zero","one","two","three","none","", nil]) == %{
  			"zero" => "zero",
  			"one" => "one",
  			"two" => "two",
  			"none" => nil }
  	end

  end

end