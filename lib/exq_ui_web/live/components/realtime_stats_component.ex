defmodule ExqUIWeb.RealtimeStatsComponent do
  use ExqUIWeb, :live_component
  alias ExqUI.Queue

  @tick_interval 5_000

  @impl true
  def mount(socket) do
    if connected?(socket) do
      send_update_after(__MODULE__, [id: "realtime-stats"], 0)
    end

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    stats = Queue.realtime_stats(assigns[:stats])

    send_update_after(
      __MODULE__,
      [id: "realtime-stats", stats: stats],
      @tick_interval
    )

    socket = push_event(socket, "append-point", Map.take(stats, [:processed, :failed]))
    {:ok, assign(socket, stats: stats, tick_interval: @tick_interval)}
  end
end
