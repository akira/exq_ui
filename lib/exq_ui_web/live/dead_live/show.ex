defmodule ExqUIWeb.DeadLive.Show do
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @impl true
  def mount(%{"score" => score, "jid" => jid}, _session, socket) do
    socket =
      assign(socket, :actions, [
        %{name: "delete", label: "Delete"},
        %{name: "dequeue_now", label: "Retry Now"}
      ])

    {:ok, assign(socket, job_details(score, jid))}
  end

  @impl true
  def handle_event("delete", %{"raw" => raw_job}, socket) do
    :ok = Queue.remove_dead_jobs([raw_job])
    {:noreply, push_redirect(socket, to: Routes.dead_index_path(socket))}
  end

  @impl true
  def handle_event("dequeue_now", %{"raw" => raw_job}, socket) do
    :ok = Queue.dequeue_dead_jobs([raw_job])
    {:noreply, push_redirect(socket, to: Routes.dead_index_path(socket))}
  end

  defp job_details(score, jid) do
    item = Queue.find_dead_job(score, jid)
    %{item: item}
  end
end
