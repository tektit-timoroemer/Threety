defmodule Fourty.Users.EditPW do
	use Ecto.Schema
	import Ecto.Changeset
	alias Fourty.Validations

	# schema to be used for the change password dialog

	embedded_schema do
		field :password_old, Fourty.TypeTrimmedString
		field :password, Fourty.TypeTrimmedString
    field :password_confirmation, Fourty.TypeTrimmedString
	end

	@doc false
	def changeset(user, attrs) do
		user
			|> cast(attrs, [:password_old, :password, :password_confirmation])
			|> validate_required([:password_old, :password, :password_confirmation])
			|> Validations.validate_password(:password)
	    |> validate_confirmation(:password)
	end

end