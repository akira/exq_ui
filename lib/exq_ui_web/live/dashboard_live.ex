defmodule ExqUIWeb.DashboardLive do
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @tick_interval 10000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :tick, @tick_interval)

    {:ok, assign(socket, stats: Queue.stats())}
  end

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @tick_interval)
    {:noreply, assign(socket, :stats, Queue.stats())}
  end
end
