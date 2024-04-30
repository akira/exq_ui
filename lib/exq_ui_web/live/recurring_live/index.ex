defmodule ExqUIWeb.RecurringLive.Index do
  @moduledoc false
  use ExqUIWeb, :live_view
  @compile {:no_warn_undefined, [ExqScheduler]}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, schedules_details())}
  end

  @impl true
  def handle_event("enqueue_now", %{"name" => name}, socket) do
    :ok = ExqScheduler.enqueue_now(scheduler(), String.to_atom(name))
    {:noreply, assign(socket, schedules_details())}
  end

  @impl true
  def handle_event(
        "active",
        %{"active" => %{"name" => name, "enabled" => enabled}, "_target" => ["active", "toggle"]},
        socket
      ) do
    case enabled do
      "false" -> :ok = ExqScheduler.disable(scheduler(), String.to_atom(name))
      "true" -> :ok = ExqScheduler.enable(scheduler(), String.to_atom(name))
    end

    {:noreply, assign(socket, schedules_details())}
  end

  @impl true
  def handle_event("active", _, socket) do
    {:noreply, socket}
  end

  defp schedules_details() do
    schedules = ExqScheduler.schedules(scheduler())
    %{items: schedules}
  end

  defp scheduler do
    Application.get_env(:exq_ui_fork, :exq_scheduler_name, ExqScheduler)
  end
end
