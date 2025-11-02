defmodule ExqUIWeb.BusyLive.Index do
  @moduledoc false
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @impl true

  def mount(_params, %{"config" => config}, socket) do
    processes = Queue.list_current_jobs(config)

    {:ok,
     assign(socket, %{
       config: config,
       columns: [
         %{header: "Node", accessor: fn item -> item.process.host end},
         %{header: "PID", accessor: fn item -> item.process.pid end},
         %{header: "JID", accessor: fn item -> item.job.jid end},
         %{header: "Queue", accessor: fn item -> item.job.queue end},
         %{header: "Module", accessor: fn item -> item.job.class end},
         %{
           header: "Arguments",
           text_break: true,
           accessor: fn item -> inspect(item.job.args) end
         },
         %{header: "Started", accessor: fn item -> human_time(item.process.run_at) end}
       ],
       actions: [
         %{name: "cancel", label: "Cancel"}
       ],
       items: processes,
       total: 0,
       current_page: 1,
       page_size: 1,
       nodes: Queue.list_nodes(config)
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
  def handle_event("action", %{"table" => %{"action" => "cancel"} = params}, socket) do
    config = socket.assigns.config

    Map.delete(params, "action")
    |> Map.values()
    |> Enum.each(fn raw ->
      %{"node_id" => node_id, "jid" => jid, "pid" => pid} = Jason.decode!(raw)

      :ok =
        Queue.send_signal(
          config,
          node_id,
          "CANCEL:#{Jason.encode!(%{jid: jid, pid: pid})}"
        )
    end)

    # Wait for the signal to be processed (5 seconds poll)
    Process.sleep(7000)
    socket = assign(socket, :items, Queue.list_current_jobs(config))

    {:noreply, socket}
  end

  @impl true
  def handle_event("signal", _, socket) do
    {:noreply, socket}
  end
end
