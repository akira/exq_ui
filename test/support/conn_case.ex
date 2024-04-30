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
  use Phoenix.Endpoint, otp_app: :exq_ui_fork

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
    :ok = populate()
    on_exit(fn -> Redix.command!(:redix, ["FLUSHALL"]) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  defp populate do
    Redix.command!(:redix, ["FLUSHALL"])

    Enum.each(commands(), fn command ->
      Redix.command!(:redix, command)
    end)

    :ok
  end

  defp commands do
    [
      ["SET", "exq:stat:processed", "5456"],
      ["SET", "exq:stat:failed", "4949"],
      ["SADD", "exq:queues", "hard"],
      [
        "LPUSH",
        "exq:queue:hard",
        ~S({"args":[428],"class":"Hardworker","enqueued_at":1638553683.274524,"jid":"24b09253-1bbe-4d8a-804a-582d3541d31b","queue":"hard","retry":3})
      ],
      [
        "ZADD",
        "exq:schedule",
        "1638590048.877036",
        ~S({"args":[509],"class":"Hardworker","enqueued_at":1638589118.877069,"jid":"eac6e91d-8863-4bc5-af46-d0182966e81f","queue":"hard","retry":3})
      ],
      [
        "ZADD",
        "exq:schedule",
        "1638553975.276011",
        ~S({"args":[864],"class":"Hardworker","enqueued_at":1638553683.276065,"jid":"56367c04-f0d1-4da4-bbd6-79663dacfe89","queue":"hard","retry":3})
      ],
      [
        "ZADD",
        "exq:retry",
        "1638589129.870564",
        ~S({"args":[499],"class":"Hardworker","enqueued_at":1638589112.858943,"error_class":null,"error_message":"{:bad, :reason}","failed_at":1638589113.870502,"finished_at":null,"jid":"537bc07e-4f22-4eb2-a0c3-9f79ca06c489","processor":null,"queue":"hard","retried_at":1638589113.870502,"retry":3,"retry_count":1})
      ],
      [
        "ZADD",
        "exq:retry",
        "1638589163.814416",
        ~S({"args":[235],"class":"Hardworker","enqueued_at":1638589086.784998,"error_class":null,"error_message":"{%RuntimeError{message: \"hello\"},\n [\n   {Hardworker, :perform, 1, [file: 'lib/hardworker.ex', line: 11]},\n   {Exq.Worker.Server, :\"-dispatch_work/3-fun-0-\", 4,\n    [file: 'lib/exq/worker/server.ex', line: 179]},\n   {Task.Supervised, :invoke_mfa, 2, [file: 'lib/task/supervised.ex', line: 90]},\n   {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 226]}\n ]}","failed_at":1638589087.814353,"finished_at":null,"jid":"9132fc4b-8d3a-4130-8108-9b82200ff1cf","processor":null,"queue":"hard","retried_at":1638589087.814353,"retry":3,"retry_count":1})
      ],
      [
        "ZADD",
        "exq:dead",
        "1638591628.954721",
        ~S({"args":[548],"class":"Hardworker","enqueued_at":1638591585.838613,"error_class":"ExqGenericError","error_message":":kill","failed_at":1638591585.956837,"finished_at":null,"jid":"f93d8758-e967-4cf5-9987-01f94a98eb12","processor":null,"queue":"hard","retried_at":1638591628.954539,"retry":1,"retry_count":1})
      ],
      [
        "ZADD",
        "exq:dead",
        "1638591636.976679",
        ~S({"args":[409],"class":"Hardworker","enqueued_at":1638591589.852777,"error_class":"ExqGenericError","error_message":"{%RuntimeError{message: \"hello\"},\n [\n   {Hardworker, :perform, 1, [file: 'lib/hardworker.ex', line: 11]},\n   {Exq.Worker.Server, :\"-dispatch_work/3-fun-0-\", 4,\n    [file: 'lib/exq/worker/server.ex', line: 179]},\n   {Task.Supervised, :invoke_mfa, 2, [file: 'lib/task/supervised.ex', line: 90]},\n   {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 226]}\n ]}","failed_at":1638591589.969617,"finished_at":null,"jid":"b8f7d783-7993-4759-a866-fc4af5db8e1f","processor":null,"queue":"hard","retried_at":1638591636.976439,"retry":1,"retry_count":1})
      ],
      ["SADD", "exq:processes", "anantha-ubuntu"],
      [
        "HMSET",
        "exq:anantha-ubuntu",
        "info",
        ~S({"busy":2,"concurrency":0,"hostname":"anantha-ubuntu","identity":"anantha-ubuntu","labels":[],"pid":"56630","queues":["hard","soft"],"quiet":false,"started_at":1638592035.715455,"tag":""}),
        "busy",
        "2",
        "beat",
        "1638592040.717764",
        "quiet",
        "false"
      ],
      [
        "HSET",
        "exq:anantha-ubuntu:workers",
        "#PID<0.313.0>",
        ~S({"host":"anantha-ubuntu","payload":"{\"args\":[958],\"class\":\"Hardworker\",\"enqueued_at\":1638591977.211016,\"error_class\":null,\"error_message\":\"{:erlang_error,\\n [\\n   {Hardworker, :perform, 1, [file: 'lib/hardworker.ex', line: 15]},\\n   {Exq.Worker.Server, :\\\"-dispatch_work/3-fun-0-\\\", 4,\\n    [file: 'lib/exq/worker/server.ex', line: 179]},\\n   {Task.Supervised, :invoke_mfa, 2, [file: 'lib/task/supervised.ex', line: 90]},\\n   {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 226]}\\n ]}\",\"failed_at\":1638591978.22883,\"finished_at\":null,\"jid\":\"0aec2714-9032-4574-ae45-a2037c874d9f\",\"processor\":null,\"queue\":\"hard\",\"retried_at\":1638591978.22883,\"retry\":1,\"retry_count\":1}","pid":"#PID<0.313.0>","queue":"hard","run_at":1638592042.761834})
      ],
      [
        "HSET",
        "exq:anantha-ubuntu:workers",
        "#PID<0.314.0>",
        ~S({"host":"anantha-ubuntu","payload":"{\"args\":[85],\"class\":\"Hardworker\",\"enqueued_at\":1638592042.750244,\"error_class\":null,\"error_message\":null,\"failed_at\":null,\"finished_at\":null,\"jid\":\"790fa550-08a4-42de-93e4-8c09c867befe\",\"processor\":null,\"queue\":\"hard\",\"retried_at\":null,\"retry\":1,\"retry_count\":null}","pid":"#PID<0.314.0>","queue":"hard","run_at":1638592042.76202})
      ]
    ]
  end
end
