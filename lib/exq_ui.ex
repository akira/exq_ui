defmodule ExqUi do
  require Logger
  alias Exq.Enqueuer.Supervisor, as: EnqueuerSupervisor

  use Application

  # OTP Application
  def start(_type, args) do
    # port for UI
    webport = Application.get_env(:exq_ui, :webport, 4040)

    # namespace for UI endpoint
    web_namespace = Application.get_env(:exq_ui, :web_namespace, "")

    redis_namespace = Application.get_env(:exq, :namespace, "exq")

    # Start exq enqueuer supervisor
    {:ok, _} = EnqueuerSupervisor.start_link

    api_name = EnqueuerSupervisor.server_name(nil)
    exq_opts = [name: api_name]

    # Check connection
    {:ok, _} = Exq.Api.queue_size(api_name)

    IO.puts "Starting ExqUI on Port #{webport}"

    value = Plug.Adapters.Cowboy.http ExqUi.RouterPlug,
      [namespace: web_namespace, exqopts: exq_opts], port: webport
  end
end
