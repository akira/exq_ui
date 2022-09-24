import Config

# Print only warnings and errors during test
config :logger, level: :warn

config :exq_ui, DemoWeb.Endpoint,
  secret_key_base: "JUrii8hEdYZjAo/LHUziUO1xx0ViDK+I1yYDVvNrLpcYWH93l4kSBvWsbfGwJRu5",
  live_view: [signing_salt: "jhwmDSe0"],
  pubsub_server: ExqUI.PubSub
