# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ticket_BE,
  ecto_repos: [Ticket_BE.Repo],
  generators: [timestamp_type: :utc_datetime]

config :ticket_BE, Ticket_BE.Guardian,
  issuer: "ticket_BE",
  secret_key: "J/y/ZuK+jn7RFrXsl06ZQGqEeahxwW1qxWyN7CU+FY2GBtO1WH7amDjLhhR0s5eB",
  # secret_key: System.get_env("SECRET_KEY") || "this-is-a-secret-key_8Basd12Oasdk123Lasdasdasd"
  # serializer: Ticket_BE.GuardianSerializer,
  allowed_algos: ["HS512"] # optional
  # verify_module: Guardian.JWT,  # optional
  # issuer: "Ticket_BE", # optional
  # # ttl: { 1, :days },
  # allowed_drift: 2000,
  # verify_issuer: true # optional

# Configures the endpoint
config :ticket_BE, Ticket_BEWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: Ticket_BEWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Ticket_BE.PubSub,
  live_view: [signing_salt: "dv/mMBLp"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
