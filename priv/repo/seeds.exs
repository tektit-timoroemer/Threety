# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fourty.Repo.insert!(%Fourty.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Fourty.Users.create_user(%{
	username: "Papa",
	email: "papa.test@test.test",
	rate: 123,
	password: "test1234TEST!",
	password_confirmation: "test1234TEST!",
	role: 1})

Fourty.Users.create_user(%{
	username: "Test",
	email: "test.test@test.test",
	rate: 123,
	password: "test1234TEST!",
	password_confirmation: "test1234TEST!",
	role: 0})
