defmodule ExqUIWeb.QueueLive.Show do
  use ExqUIWeb, :live_view
  alias Exq.Api

  @page_size 30

  @impl true
  def mount(%{"name" => name} = params, _session, socket) do
    socket =
      assign(socket, :columns, [
        %{header: "Module", accessor: fn item -> item.job.class end},
        %{header: "Arguments", accessor: fn item -> inspect(item.job.args) end}
      ])
      |> assign(:actions, [
        %{name: "delete", label: "Delete"}
      ])

    {:ok, assign(socket, jobs_details(name, params["page"] || "1"))}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete"} = params}, socket) do
    name = socket.assigns.name

    raw_jobs =
      Map.delete(params, "action")
      |> Map.values()

    unless Enum.empty?(raw_jobs) do
      :ok = Api.remove_enqueued_jobs(Exq.Api, name, raw_jobs)
    end

    socket = assign(socket, jobs_details(name, socket.assigns.current_page))
    {:noreply, socket}
  end

  @impl true
  def handle_event("page", %{"page" => page}, socket) do
    name = socket.assigns.name

    socket =
      assign(socket, jobs_details(name, page))
      |> push_patch(to: Routes.queue_show_path(socket, :index, name, page: page))

    {:noreply, socket}
  end

  defp jobs_details(name, page) when is_binary(page) do
    page =
      case Integer.parse(page) do
        :error -> 1
        {page, _} -> page
      end

    jobs_details(name, page)
  end

  defp jobs_details(name, page) do
    {:ok, total} = Api.queue_size(Exq.Api, name)

    {:ok, raw_jobs} =
      Api.jobs(Exq.Api, name, raw: true, offset: @page_size * (page - 1), size: @page_size)

    items =
      Enum.map(raw_jobs, fn json ->
        job = Exq.Support.Job.decode(json)
        %{job: job, id: job.jid, raw: json}
      end)

    %{items: items, name: name, total: total, current_page: page, page_size: @page_size}
  end
end
