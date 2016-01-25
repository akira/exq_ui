defmodule ExqUi do
  use Application

  # OTP Application
  def start(_type, _args) do
    launch_app
  end

  def launch_app do
    web_port = Application.get_env(:exq_ui, :web_port, 4040)
    web_namespace = Application.get_env(:exq_ui, :web_namespace, "")

    {:ok, _} = Exq.start_link(mode: :api)
    api_name = Exq.Api.Server.server_name(nil)
    {:ok, _} = Exq.Api.queue_size(api_name)
    IO.puts "Starting ExqUI on Port #{web_port}"

    Plug.Adapters.Cowboy.http ExqUi.RouterPlug,
      [namespace: web_namespace, exq_opts: [name: api_name]], port: web_port
  end
end
