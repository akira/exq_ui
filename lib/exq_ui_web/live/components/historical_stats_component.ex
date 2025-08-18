defmodule ExqUIWeb.HistoricalStatsComponent do
  @moduledoc false
  use ExqUIWeb, :live_component
  alias ExqUI.Queue

  @impl true
  def mount(socket) do
    socket = assign(socket, :days, 30)
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      assign(socket, :config, assigns.config)
      |> send_points()

    {:ok, socket}
  end

  @impl true
  def handle_event("days", %{"days" => days}, socket) do
    {days, ""} = Integer.parse(days)
    days = Enum.min([180, Enum.max([0, days])])

    config = socket.assigns.config

    socket =
      assign(socket, :days, days)
      |> send_points()
      |> push_patch(to: Routes.dashboard_path(config, days: days))

    {:noreply, socket}
  end

  defp send_points(socket) do
    config = socket.assigns.config
    stats = Queue.historical_stats(config, socket.assigns[:days])
    push_event(socket, "replace-points", %{points: stats})
  end
end
