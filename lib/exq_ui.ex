defmodule ExqUi do
  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    launch_app()
  end

  def launch_app do
    web_port = Application.get_env(:gh_exq_ui, :web_port, 4040)
    web_namespace = Application.get_env(:gh_exq_ui, :web_namespace, "")
    run_server? = Application.get_env(:gh_exq_ui, :server, true)

    api_name = Exq.Api.Server.server_name(ExqUi)

    unless Process.whereis(api_name) do
      {:ok, _} = Exq.start_link(name: ExqUi, mode: :api)
    end

    {_status, _} = Exq.Api.queue_size(api_name)

    if run_server? do
      IO.puts "Starting ExqUI on Port #{web_port}"
      cowboy_version_adapter().http ExqUi.RouterPlug,
        [namespace: web_namespace, exq_opts: [name: api_name]], port: web_port
    end
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def cowboy_version_adapter() do
    case minor_elixir_version() >= 4 do
      true -> plug_adapter_cowboy(otp_version())
      _ -> Plug.Adapters.Cowboy
    end
  end

  def otp_version do
    :erlang.system_info(:otp_release)
    |> to_string()
    |> String.to_integer()
  end

  def minor_elixir_version do
    {_, version} = Version.parse(System.version)
    version.minor
  end

  defp plug_adapter_cowboy(otp_version) when otp_version < 19, do: Plug.Adapters.Cowboy
  defp plug_adapter_cowboy(otp_version) when otp_version in 19..20, do: Plug.Adapters.Cowboy2
  defp plug_adapter_cowboy(otp_version) when otp_version >= 21, do: Plug.Cowboy
end
