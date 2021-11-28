defmodule ExqUIWeb.QueueLive.Show do
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @page_size 30

  @impl true
  def mount(%{"name" => name} = params, _session, socket) do
    socket =
      assign(socket, :columns, [
        %{header: "Module", accessor: fn item -> item.job.class end},
        %{header: "Arguments", accessor: fn item -> inspect(item.job.args) end}
      ])
      |> assign(:actions, [
        %{name: "delete", label: "Delete"},
        %{name: "delete_all", label: "Delete All"}
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

    :ok = Queue.remove_enqueued_jobs(name, raw_jobs)

    socket = assign(socket, jobs_details(name, socket.assigns.current_page))
    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete_all"}}, socket) do
    name = socket.assigns.name
    :ok = Queue.remove_queue(name)
    socket = assign(socket, jobs_details(name, "1"))
    {:noreply, socket}
  end

  @impl true
  def handle_event("page", %{"page" => page}, socket) do
    name = socket.assigns.name

    socket =
      assign(socket, jobs_details(name, page))
      |> push_patch(to: Routes.queue_show_path(socket, name, page: page))

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
    total = Queue.count_enqueued_jobs(name)
    items = Queue.list_enqueued_jobs(name, offset: @page_size * (page - 1), size: @page_size)
    %{items: items, name: name, total: total, current_page: page, page_size: @page_size}
  end
end
