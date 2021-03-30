defmodule Fourty.SetupTest do
#
# tests Fourty.Setup
#
	use Fourty.DataCase
	import Fourty.Setup

	describe "fixtures" do

		test "client" do
			c1 = client_fixture()
			c2 = client_fixture()
			refute same_clients?(c1, c2)
		end

		test "project - same client" do
			p1 = project_fixture()
			p2 = project_fixture(%{client_id: p1.client_id})
			refute same_projects?(p1, p2)
		end

		test "project - different clients" do
			p1 = project_fixture()
			p2 = project_fixture()
			refute same_projects?(p1, p2)
			refute p1.client_id == p2.client_id
		end

		test "order - different projects" do
			o1 = order_fixture()
			o2 = order_fixture()
			refute same_orders?(o1, o2)
			refute o1.project_id == o2.project_id
		end

		test "order - same project" do
			o1 = order_fixture()
			o2 = order_fixture(%{project_id: o1.project_id})
			refute same_orders?(o1, o2)
		end

		test "account - same project" do
			a1 = account_fixture()
			a2 = account_fixture(%{project_id: a1.project_id})
			refute same_accounts?(a1, a2)
		end

		test "account - different projects" do
			a1 = account_fixture()
			a2 = account_fixture()
			refute same_accounts?(a1, a2)
			refute a1.project_id == a2.project_id
 		end

 		test "deposit - different account, order" do
 			d1 = deposit_fixture()
 			d2 = deposit_fixture()
 			refute same_deposits?(d1, d2)
 			refute d1.account_id == d2.account_id
 			refute d1.order_id == d2.order_id
 		end

 		test "deposit - same account, different order" do
 			d1 = deposit_fixture()
 			d2 = deposit_fixture(%{account_id: d1.account_id})
 			refute same_deposits?(d1, d2)
 			assert d1.account_id == d2.account_id
 			refute d1.order_id == d2.order_id
 		end

 		test "deposit - different account, same order" do
 			d1 = deposit_fixture()
 			d2 = deposit_fixture(%{order_id: d1.order_id})
 			refute same_deposits?(d1, d2)
 			refute d1.account_id == d2.account_id
 			assert d1.order_id == d2.order_id
 		end

 		test "deposit - same account, same order" do
 			d1 = deposit_fixture()
 			d2 = deposit_fixture(%{account_id: d1.account_id, order_id: d1.order_id})
 			refute same_deposits?(d1, d2)
 			assert d1.account_id == d2.account_id
 			assert d1.order_id == d2.order_id
 		end

 		test "user" do
 			u1 = user_fixture()
 			u2 = user_fixture()
 			refute same_users?(u1, u2)
 		end

 		test "work_item - different users, different accounts" do
 			w1 = work_item_fixture()
 			w2 = work_item_fixture()
 			refute same_work_items?(w1, w2)
 			refute w1.user_id == w2.user_id
 			refute w1.account_id == w2.account_id
 		end

 		test "work_item - same user, different accounts" do
 			w1 = work_item_fixture()
 			w2 = work_item_fixture(%{user_id: w1.user_id})
 			refute same_work_items?(w1, w2)
 			assert w1.user_id == w2.user_id
 			refute w1.account_id == w2.account_id
 		end

 		test "work_item - different users, same account" do
 			w1 = work_item_fixture()
 			w2 = work_item_fixture(%{account_id: w1.account_id})
 			refute same_work_items?(w1, w2)
 			refute w1.user_id == w2.user_id
 			assert w1.account_id == w2.account_id
 		end

 		test "work_item - same user, same account" do
 			w1 = work_item_fixture()
 			w2 = work_item_fixture(
 				%{user_id: w1.user_id, account_id: w1.account_id})
 			refute same_work_items?(w1, w2)
 			assert w1.user_id == w2.user_id
 			assert w1.account_id == w2.account_id
 		end
 	end
end