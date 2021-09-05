defmodule ExqUIWeb.StatsComponent do
  use ExqUIWeb, :live_component
  alias ExqUI.Queue

  @tick_interval 5000

  @impl true
  def mount(socket) do
    if connected?(socket) do
      send_update_after(__MODULE__, [id: "stats"], @tick_interval)
    end

    {:ok, socket}
  end

  @impl true
  def update(_assigns, socket) do
    send_update_after(__MODULE__, [id: "stats"], @tick_interval)
    {:ok, assign(socket, :stats, Queue.stats())}
  end
end
