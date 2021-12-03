defmodule DemoWeb.Router do
  use Phoenix.Router
  import ExqUIWeb.Router

  pipeline :browser do
    plug :fetch_session
    plug :protect_from_forgery
  end

  scope "/", DemoWeb do
    pipe_through :browser
    live_exq_ui("/")
  end
end

defmodule DemoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :exq_ui

  @session_options [
    store: :cookie,
    key: "_exq_ui_key",
    signing_salt: "Y3AT90O7"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.Session, @session_options
  plug DemoWeb.Router
end

defmodule ExqUI.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
      import ExqUI.ConnCase

      @endpoint DemoWeb.Endpoint
    end
  end

  setup do
    Redix.command!(:redix, ["FLUSHALL"])
    populate()
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  defp populate do
    Enum.each(commands(), fn command ->
      Redix.command!(:redix, command)
    end)
  end

  defp commands do
    [
      ["SET", "exq:stat:processed", "5456"],
      ["SET", "exq:stat:failed", "4949"],
      ["SADD", "exq:queues", "hard"],
      [
        "LPUSH",
        "exq:queue:hard",
        ~s({"args":[428],"class":"Hardworker","enqueued_at":1638553683.274524,"jid":"24b09253-1bbe-4d8a-804a-582d3541d31b","queue":"hard","retry":3})
      ],
      [
        "ZADD",
        "exq:schedule",
        "1638553975.276011",
        ~s({"args":[864],"class":"Hardworker","enqueued_at":1638553683.276065,"jid":"56367c04-f0d1-4da4-bbd6-79663dacfe89","queue":"hard","retry":3})
      ]
    ]
  end
end
