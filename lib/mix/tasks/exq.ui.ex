defmodule Mix.Tasks.Exq.Ui do
  use Mix.Task

  @shortdoc "Starts the Exq UI Server"

  def run(args) do

    web_namespace = Application.get_env(:exq_ui, :web_namespace, "")
    web_port = Application.get_env(:exq_ui, :web_port, 4040)

    # Start exq enqueuer supervisor
    {:ok, _} = Exq.Enqueuer.Supervisor.start_link

    api_name = Exq.Enqueuer.Server.server_name(nil)
    exq_opts = [name: api_name]

    # Check connection
    {:ok, _} = Exq.Api.queue_size(api_name)

    IO.puts "Starting ExqUI on Port #{web_port}"

    value = Plug.Adapters.Cowboy.http ExqUi.RouterPlug,
      [namespace: web_namespace, exqopts: exq_opts], port: web_port

    :timer.sleep(:infinity)
  end

end
