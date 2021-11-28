defmodule ExqUIWeb.QueueLive.Index do
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :queues, Queue.list_queues())}
  end

  @impl true
  def handle_event("delete", %{"name" => name}, socket) do
    :ok = Queue.remove_queue(name)
    {:noreply, assign(socket, :queues, Queue.list_queues())}
  end
end
