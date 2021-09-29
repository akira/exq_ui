defmodule ExqUIWeb.HistoricalStatsComponent do
  use ExqUIWeb, :live_component
  alias ExqUI.Queue

  @impl true
  def mount(socket) do
    socket = assign(socket, :days, 30)
    {:ok, socket}
  end

  @impl true
  def update(_assigns, socket) do
    socket = send_points(socket)
    {:ok, socket}
  end

  @impl true
  def handle_event("days", %{"days" => days}, socket) do
    {days, ""} = Integer.parse(days)
    days = Enum.min([180, Enum.max([0, days])])

    socket =
      assign(socket, :days, days)
      |> send_points()
      |> push_patch(to: Routes.dashboard_path(socket, days: days))

    {:noreply, socket}
  end

  defp send_points(socket) do
    stats = Queue.historical_stats(socket.assigns[:days])
    push_event(socket, "replace-points", %{points: stats})
  end
end
