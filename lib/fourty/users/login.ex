defmodule Fourty.Users.Login do
	use Ecto.Schema
	import Ecto.Changeset

	# schema to be used for the login dialog

	embedded_schema do
		field :username, Fourty.TypeTrimmedString
		field :password_plain, Fourty.TypeTrimmedString
	end

	@doc false
	def changeset(user, attrs) do
		user
			|> cast(attrs, [:username, :password_plain])
			|> validate_required([:username, :password_plain])
	end

end