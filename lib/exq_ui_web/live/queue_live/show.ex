defmodule ExqUIWeb.QueueLive.Show do
  use ExqUIWeb, :live_view

  alias Exq.Api

  @impl true
  def mount(%{"name" => name}, _session, socket) do
    {:ok, assign(socket, name: name, jobs: jobs(name))}
  end

  @impl true
  def handle_event("delete", %{"raw" => json, "queue" => name}, socket) do
    :ok = Api.remove_enqueued_job(Exq.Api, name, json)
    {:noreply, assign(socket, name: name, jobs: jobs(name))}
  end

  defp jobs(name) do
    {:ok, raw_jobs} = Api.jobs(Exq.Api, name, raw: true)
    Enum.map(raw_jobs, fn json -> %{job: Exq.Support.Job.decode(json), raw: json} end)
  end
end
