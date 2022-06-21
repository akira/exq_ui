Logger.configure(level: :debug)

# Configures the endpoint
Application.put_env(:exq_ui, DemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JUrii8hEdYZjAo/LHUziUO1xx0ViDK+I1yYDVvNrLpcYWH93l4kSBvWsbfGwJRu5",
  live_view: [signing_salt: "jhwmDSe0"],
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  check_origin: false,
  pubsub_server: ExqUI.PubSub,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      System.get_env("NODE_ENV") || "production",
      "--watch-stdin",
      cd: "assets"
    ]
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/exq_ui_web/(live|views)/.*(ex)$",
      ~r"lib/exq_ui_web/templates/.*(ex)$"
    ]
  ]
)

Application.put_env(:phoenix, :serve_endpoints, true)

defmodule DemoWeb.Router do
  use Phoenix.Router
  import ExqUIWeb.Router

  pipeline :browser do
    plug :fetch_session
    plug :protect_from_forgery
  end

  scope "/", DemoWeb do
    pipe_through :browser

    live_exq_ui("/exq", live_socket_path: "/exq/live")
  end
end

defmodule DemoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :exq_ui

  @session_options [
    store: :cookie,
    key: "_exq_ui_key",
    signing_salt: "Y3AT90O7"
  ]

  socket "/exq/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader

  plug Plug.RequestId

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.Session, @session_options
  plug DemoWeb.Router
end

Task.async(fn ->
  children = [
    {Phoenix.PubSub, name: ExqUI.PubSub},
    DemoWeb.Endpoint
  ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  Process.sleep(:infinity)
end)
|> Task.await(:infinity)
