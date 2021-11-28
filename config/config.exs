use Mix.Config

config :exq,
  name: Exq,
  mode: :api,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq"

config :exq_ui,
  api_name: Exq.Api

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
