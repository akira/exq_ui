defmodule ExqUIWeb.BusyLive.Index do
  @moduledoc false
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @impl true

  def mount(_params, %{"config" => config}, socket) do
    {:ok,
     assign(socket, %{
       config: config,
       nodes: Queue.list_nodes(config),
       jobs: Queue.list_current_jobs(config)
     })}
  end

  @impl true
  def handle_event(
        "signal",
        %{
          "signal" => %{"name" => "TSTP", "node_id" => node_id},
          "_target" => ["signal", "quiet"]
        },
        socket
      ) do
    config = socket.assigns.config
    :ok = Queue.send_signal(config, node_id, "TSTP")

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

  @impl true
  def handle_event("signal", _, socket) do
    {:noreply, socket}
  end
end
