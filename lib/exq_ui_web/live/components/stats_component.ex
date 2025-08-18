defmodule ExqUIWeb.StatsComponent do
  @moduledoc false
  use ExqUIWeb, :live_component
  alias ExqUI.Queue

  @impl true
  def update(assigns, socket) do
    config = assigns.config
    interval = assigns[:refresh_interval] || socket.assigns[:refresh_interval] || 5
    timer_ref = send_update_after(__MODULE__, [id: "stats", config: config], interval * 1000)

    assigns =
      Map.put(assigns, :stats, Queue.stats(config))
      |> Map.put(:timer_ref, timer_ref)

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("refresh-interval", %{"interval" => interval}, socket) do
    if socket.assigns.timer_ref do
      Process.cancel_timer(socket.assigns.timer_ref)
    end

    timer_ref =
      send_update_after(__MODULE__, [id: "stats", config: socket.assigns.config], interval * 1000)

    {:noreply, assign(socket, %{refresh_interval: interval, timer_ref: timer_ref})}
  end
end
