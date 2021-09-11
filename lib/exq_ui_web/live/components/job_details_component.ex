defmodule ExqUIWeb.JobDetailsComponent do
  use ExqUIWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
