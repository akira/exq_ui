use Mix.Config

config :exq,
  name: Exq,
  mode: :api,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq"

config :exq_ui,
  api_name: Exq.Api,
  exq_scheduler_name: ExqScheduler

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :exq_scheduler, :storage,
  exq_namespace: "exq",
  json_serializer: Jason

config :exq_scheduler, :redis,
  name: ExqScheduler.Redis.Client,
  child_spec: {Redix, [host: "127.0.0.1", port: 6379, name: ExqScheduler.Redis.Client]}

config :exq_scheduler, name: ExqScheduler

config :exq_scheduler, :schedules,
  hard_worker: %{
    description: "Schedule a Hardworker job every 2 minutes",
    cron: "*/2 * * * * Asia/Jakarta",
    class: "Hardworker",
    args: [435_493],
    queue: "hard"
  },
  soft_worker: %{
    description: "Schedule a Hardworker job every 3 minutes",
    cron: "*/3 * * * *",
    class: "Hardworker",
    include_metadata: true,
    args: [],
    queue: "soft"
  }
