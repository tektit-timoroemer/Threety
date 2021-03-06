use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :fourty, Fourty.Repo,
  username: "postgres",
  password: "postgres",
  database: "papas_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fourty, FourtyWeb.Endpoint,
  http: [port: 4002],
  server: false

# configuration of guardian according to: Getting Started with Guardian
config :fourty, Fourty.Users.Guardian,
  issuer: "fourty",
  secret_key: "secret_key"

# Print only warnings and errors during test
config :logger, level: :warn
