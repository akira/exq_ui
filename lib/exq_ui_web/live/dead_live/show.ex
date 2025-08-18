defmodule ExqUIWeb.DeadLive.Show do
  @moduledoc false
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @impl true
  def mount(%{"score" => score, "jid" => jid}, %{"config" => config}, socket) do
    socket =
      assign(socket, :actions, [
        %{name: "delete", label: "Delete"},
        %{name: "dequeue_now", label: "Retry Now"}
      ])
      |> assign(:config, config)

    {:ok, assign(socket, job_details(config, score, jid))}
  end

  @impl true
  def handle_event("delete", %{"raw" => raw_job}, socket) do
    config = socket.assigns.config
    :ok = Queue.remove_dead_jobs(config, [raw_job])
    {:noreply, push_redirect(socket, to: Routes.dead_index_path(config))}
  end

  @impl true
  def handle_event("dequeue_now", %{"raw" => raw_job}, socket) do
    config = socket.assigns.config
    :ok = Queue.dequeue_dead_jobs(config, [raw_job])
    {:noreply, push_redirect(socket, to: Routes.dead_index_path(config))}
  end

  defp job_details(config, score, jid) do
    item = Queue.find_dead_job(config, score, jid)
    %{item: item}
  end
end
