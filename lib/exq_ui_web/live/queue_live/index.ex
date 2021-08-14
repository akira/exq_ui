defmodule ExqUIWeb.QueueLive.Index do
  use ExqUIWeb, :live_view

  alias Exq.Api

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :queues, list_queues())}
  end

  @impl true
  def handle_event("delete", %{"name" => name}, socket) do
    :ok = Api.remove_queue(Exq.Api, name)
    {:noreply, assign(socket, :queues, list_queues())}
  end

  defp list_queues do
    {:ok, queues} = Api.queue_size(Exq.Api)
    Enum.map(queues, fn {name, count} -> %{name: name, count: count} end)
  end
end
