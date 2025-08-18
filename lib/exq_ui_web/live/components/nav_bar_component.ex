defmodule ExqUIWeb.NavBarComponent do
  @moduledoc false
  use ExqUIWeb, :live_component

  @impl true
  def update(assigns, socket) do
    config = assigns.config

    exq_scheduler_name =
      Map.get_lazy(config, :exq_scheduler_name, fn ->
        Application.get_env(:exq_ui, :exq_scheduler_name)
      end)

    {:ok,
     assign(socket, :config, assigns.config) |> assign(:exq_scheduler_name, exq_scheduler_name)}
  end
end
