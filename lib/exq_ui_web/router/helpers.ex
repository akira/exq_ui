defmodule ExqUIWeb.Router.Helpers do
  @moduledoc false
  def dashboard_path(config, params \\ %{}), do: build(config, "/", params)
  def busy_index_path(config, params \\ %{}), do: build(config, "/busy", params)

  def queue_index_path(config, params \\ %{}),
    do: build(config, "/queues", params)

  def queue_show_path(config, queue, params \\ %{}),
    do: build(config, "/queues/#{queue}", params)

  def retry_index_path(config, params \\ %{}),
    do: build(config, "/retries", params)

  def recurring_index_path(config, params \\ %{}),
    do: build(config, "/recurring", params)

  def retry_show_path(config, score, jid, params \\ %{}),
    do: build(config, "/retries/#{score}/#{jid}", params)

  def scheduled_index_path(config, params \\ %{}),
    do: build(config, "/scheduled", params)

  def scheduled_show_path(config, score, jid, params \\ %{}),
    do: build(config, "/scheduled/#{score}/#{jid}", params)

  def dead_index_path(config, params \\ %{}), do: build(config, "/dead", params)

  def dead_show_path(config, score, jid, params \\ %{}),
    do: build(config, "/dead/#{score}/#{jid}", params)

  defp build(config, path, params) do
    root = config.root

    query =
      if Enum.empty?(params) do
        ""
      else
        "?" <> Plug.Conn.Query.encode(params)
      end

    Path.join(root, path) <> query
  end
end
