defmodule Fourty.Repo do
  use Ecto.Repo,
    otp_app: :fourty,
    adapter: Ecto.Adapters.Postgres
end
