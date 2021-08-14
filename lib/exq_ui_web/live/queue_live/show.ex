defmodule ExqUIWeb.QueueLive.Show do
  use ExqUIWeb, :live_view
  alias Exq.Api

  @page_size 30

  @impl true
  def mount(%{"name" => name} = params, _session, socket) do
    {:ok, assign(socket, jobs_details(name, params["page"] || "1"))}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"raw" => json, "queue" => name}, socket) do
    :ok = Api.remove_enqueued_job(Exq.Api, name, json)
    {:noreply, assign(socket, jobs_details(name, socket.assigns.page))}
  end

  @impl true
  def handle_event("page", %{"page" => page}, socket) do
    name = socket.assigns.name

    socket =
      assign(socket, jobs_details(name, page))
      |> push_patch(to: Routes.queue_show_path(socket, :index, name, page: page))

    {:noreply, socket}
  end

  defp jobs_details(name, page) do
    current_page =
      case Integer.parse(page) do
        :error -> 1
        {page, _} -> page
      end

    {:ok, total} = Api.queue_size(Exq.Api, name)

    {:ok, raw_jobs} =
      Api.jobs(Exq.Api, name, raw: true, offset: @page_size * (current_page - 1), size: @page_size)

    jobs = Enum.map(raw_jobs, fn json -> %{job: Exq.Support.Job.decode(json), raw: json} end)
    %{jobs: jobs, name: name, total: total, current_page: current_page, page_size: @page_size}
  end
end
