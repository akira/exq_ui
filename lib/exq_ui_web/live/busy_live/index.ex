defmodule ExqUIWeb.BusyLive.Index do
  @moduledoc false
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{nodes: Queue.list_nodes(), jobs: Queue.list_current_jobs()})}
  end

  @impl true
  def handle_event(
        "signal",
        %{"signal" => %{"name" => "TSTP", "node_id" => node_id}},
        socket
      ) do
    :ok = Queue.send_signal(node_id, "TSTP")

    nodes =
      Enum.map(socket.assigns.nodes, fn node ->
        if node.identity == node_id do
          %{node | quiet: true}
        else
          node
        end
      end)

    socket = assign(socket, :nodes, nodes)

    {:noreply, socket}
  end
end
