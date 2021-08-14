# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :exq,
  name: Exq,
  mode: :api,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq"

config :exq_ui,
  namespace: ExqUI

# Configures the endpoint
config :exq_ui, ExqUIWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JUrii8hEdYZjAo/LHUziUO1xx0ViDK+I1yYDVvNrLpcYWH93l4kSBvWsbfGwJRu5",
  render_errors: [view: ExqUIWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExqUI.PubSub,
  live_view: [signing_salt: "jhwmDSe0"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
