defmodule ExqUIWeb.BusyLive.Index do
  @moduledoc false
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{nodes: Queue.list_nodes(), jobs: Queue.list_current_jobs()})}
  end
end
