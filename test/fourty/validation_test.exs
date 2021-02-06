defmodule Fourty.ValidationTest do
	use ExUnit.Case

	# these tests are based on existing schemas - 

	describe "at least one" do
		alias Fourty.Accounting.Deposit
		test "standard case - two fields" do
			c = %Deposit{}
			|> Deposit.changeset(%{account_id: "1", description: "test", amount_cur: "1", amount_dur: "2"})
			assert c.valid?
		end

		test "standard case - first field" do
			c = %Deposit{}
			|> Deposit.changeset(%{account_id: "1", description: "test", amount_cur: "1"})
			assert c.valid?
		end

		test "standard case - second field" do
			c = %Deposit{}
			|> Deposit.changeset(%{account_id: "1", description: "test", amount_dur: "2"})
			assert c.valid?
		end

		test "error case - none" do
			c = %Deposit{}
			|> Deposit.changeset(%{account_id: "1", description: "test"})
			refute c.valid?
			assert Keyword.has_key?(c.errors, :amount_cur)
			assert Keyword.has_key?(c.errors, :amount_dur)
		end

	end

	describe "first date before or on second date" do
		alias Fourty.Accounting.Account
		test "standard OK case, date_start before date_end" do
			c = %Account{}
			|> Account.changeset(%{project_id: "1", name: "test",
				date_start: ~D[2010-04-17], date_end: ~D[2010-04-18]})
			assert c.valid?
		end
		test "standard OK case, date_start on date_end" do
			c = %Account{}
			|> Account.changeset(%{project_id: "1", name: "test",
				date_start: ~D[2010-04-18], date_end: ~D[2010-04-18]})
			assert c.valid?
		end
		test "error case, date_start after date_end" do
			c = %Account{}
			|> Account.changeset(%{project_id: "1", name: "test",
				date_start: ~D[2010-04-19], date_end: ~D[2010-04-18]})
			refute c.valid?
		end
		test "ignore, if none given" do
			c = %Account{}
			|> Account.changeset(%{project_id: "1", name: "test"})
			assert c.valid?
		end
		test "ignore if date_start not given" do
			c = %Account{}
			|> Account.changeset(%{project_id: "1", name: "test", date_end: ~D[2010-04-18]})
			assert c.valid?
		end
		test "ignore if date_end not given" do
			c = %Account{}
			|> Account.changeset(%{project_id: "1", name: "test", date_start: ~D[2010-04-18]})
			assert c.valid?
		end
	end

end