# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :fourty,
  ecto_repos: [Fourty.Repo]

# Configures the endpoint
config :fourty, FourtyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HoSuxi0Q+LDA4DX8qlCz/NeB9tHEY5FrhmIis8UB9cdLe1n4lRilKj14ZNa7oxF/",
  render_errors: [view: FourtyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Fourty.PubSub,
  live_view: [signing_salt: "b3porh4z"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# use Ueberauth for authentication
config :ueberauth, Ueberauth,
  providers: [
    #   facebook: {Ueberauth.Strategy.Facebook, []},
    #   github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]},
    #   google: {Ueberauth.Strategy.Google, []},
    #   slack: {Ueberauth.Strategy.Slack, []},
    #   twitter: {Ueberauth.Strategy.Twitter, []}
    identity:
      {Ueberauth.Strategy.Identity,
       [
         param_nesting: "user", 
         request_path: "/auth/identity",
         callback_path: "/auth/identity/callback",
         callback_methods: ["POST"]
       ]}
  ]

# configuration of guardian according to: Getting Started with Guardian
config :fourty, Fourty.Users.Guardian,
  issuer: "fourty",
  secret_key: "lOADCETHQ6fm62YtweIk5SH7JBBOAklVinZqrVEXUQTNjLRBpxSvKFZ7ZrEgn2rc"
  # TODO: secret_key: System.get_env("GUARDIAN_SECRET_KEY")

config :fourty, Fourty.Users.Pipeline,
  module: Fourty.Users.Guardian,
  error_handler: FourtyWeb.Controllers.ErrorHandler

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
