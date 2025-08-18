defmodule ExqUIWeb.DashboardLive do
  @moduledoc false
  use ExqUIWeb, :live_view

  @impl true
  def mount(_params, %{"config" => config}, socket) do
    {:ok, assign(socket, %{config: config})}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end
end
