defmodule ExqUIWeb.Router.Helpers do
  def dashboard_path(socket, params \\ %{}), do: build(socket, "/", params)
  def queue_index_path(socket, params \\ %{}), do: build(socket, "/queues", params)
  def queue_show_path(socket, queue, params \\ %{}), do: build(socket, "/queues/#{queue}", params)
  def retry_path(socket, params \\ %{}), do: build(socket, "/retries", params)
  def scheduled_path(socket, params \\ %{}), do: build(socket, "/scheduled", params)
  def dead_path(socket, params \\ %{}), do: build(socket, "/dead", params)

  defp build(socket, path, params) do
    root = socket.router.__helpers__.exq_ui_path(socket, :root)

    query =
      if Enum.empty?(params) do
        ""
      else
        "?" <> Plug.Conn.Query.encode(params)
      end

    root <> path <> query
  end
end
