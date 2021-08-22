defmodule ExqUIWeb.ScheduledLive do
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @page_size 30

  @impl true
  def mount(params, _session, socket) do
    socket =
      assign(socket, :columns, [
        %{header: "When", accessor: fn item -> item.scheduled_at end},
        %{header: "Queue", accessor: fn item -> item.job.queue end},
        %{header: "Module", accessor: fn item -> item.job.class end},
        %{header: "Arguments", accessor: fn item -> inspect(item.job.args) end}
      ])
      |> assign(:actions, [
        %{name: "delete", label: "Delete"},
        %{name: "delete_all", label: "Delete All"}
      ])

    {:ok, assign(socket, jobs_details(params["page"] || "1"))}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("page", %{"page" => page}, socket) do
    socket =
      assign(socket, jobs_details(page))
      |> push_patch(to: Routes.scheduled_path(socket, :index, page: page))

    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete"} = params}, socket) do
    raw_jobs =
      Map.delete(params, "action")
      |> Map.values()

    :ok = Queue.remove_scheduled_jobs(raw_jobs)
    socket = assign(socket, jobs_details(socket.assigns.current_page || "1"))
    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete_all"}}, socket) do
    :ok = Queue.remove_all_scheduled_jobs()
    socket = assign(socket, jobs_details(socket.assigns.current_page || "1"))
    {:noreply, socket}
  end

  defp jobs_details(page) when is_binary(page) do
    page =
      case Integer.parse(page) do
        :error -> 1
        {page, _} -> page
      end

    jobs_details(page)
  end

  defp jobs_details(page) do
    total = Queue.count_scheduled_jobs()
    items = Queue.list_scheduled_jobs(offset: @page_size * (page - 1), size: @page_size)
    %{items: items, total: total, current_page: page, page_size: @page_size}
  end
end
