defmodule ExqUIWeb.RecurringLive.Index do
  @moduledoc false
  use ExqUIWeb, :live_view
  @compile {:no_warn_undefined, [ExqScheduler]}

  @impl true
  def mount(_params, %{"config" => config}, socket) do
    {:ok,
     assign(socket, schedules_details(config))
     |> assign(:config, config)}
  end

  @impl true
  def handle_event("enqueue_now", %{"name" => name}, socket) do
    config = socket.assigns.config
    :ok = ExqScheduler.enqueue_now(scheduler(config), String.to_atom(name))
    {:noreply, assign(socket, schedules_details(config))}
  end

  @impl true
  def handle_event(
        "active",
        %{"active" => %{"name" => name, "enabled" => enabled}, "_target" => ["active", "toggle"]},
        socket
      ) do
    config = socket.assigns.config

    case enabled do
      "false" -> :ok = ExqScheduler.disable(scheduler(config), String.to_atom(name))
      "true" -> :ok = ExqScheduler.enable(scheduler(config), String.to_atom(name))
    end

    {:noreply, assign(socket, schedules_details(config))}
  end

  @impl true
  def handle_event("active", _, socket) do
    {:noreply, socket}
  end

  defp schedules_details(config) do
    schedules = ExqScheduler.schedules(scheduler(config))
    %{items: schedules}
  end

  defp scheduler(config) do
    Map.get_lazy(config, :exq_scheduler_name, fn ->
      Application.get_env(:exq_ui, :exq_scheduler_name)
    end)
  end
end
