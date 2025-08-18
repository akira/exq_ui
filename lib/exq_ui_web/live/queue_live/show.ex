defmodule ExqUIWeb.QueueLive.Show do
  @moduledoc false
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @page_size 30

  @impl true
  def mount(%{"name" => name} = params, %{"config" => config}, socket) do
    socket =
      assign(socket, :columns, [
        %{header: "Module", accessor: fn item -> item.job.class end},
        %{header: "Arguments", text_break: true, accessor: fn item -> inspect(item.job.args) end}
      ])
      |> assign(:actions, [
        %{name: "delete", label: "Delete"},
        %{name: "delete_all", label: "Delete All"}
      ])
      |> assign(:config, config)

    {:ok, assign(socket, jobs_details(config, name, params["page"] || "1"))}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete"} = params}, socket) do
    name = socket.assigns.name
    config = socket.assigns.config

    raw_jobs =
      Map.delete(params, "action")
      |> Map.values()

    :ok = Queue.remove_enqueued_jobs(config, name, raw_jobs)

    socket = assign(socket, jobs_details(config, name, socket.assigns.current_page))
    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete_all"}}, socket) do
    name = socket.assigns.name
    config = socket.assigns.config
    :ok = Queue.remove_queue(config, name)
    socket = assign(socket, jobs_details(config, name, "1"))
    {:noreply, socket}
  end

  @impl true
  def handle_event("page", %{"page" => page}, socket) do
    name = socket.assigns.name
    config = socket.assigns.config

    socket =
      assign(socket, jobs_details(config, name, page))
      |> push_patch(to: Routes.queue_show_path(config, name, page: page))

    {:noreply, socket}
  end

  defp jobs_details(config, name, page) when is_binary(page) do
    page =
      case Integer.parse(page) do
        :error -> 1
        {page, _} -> page
      end

    jobs_details(config, name, page)
  end

  defp jobs_details(config, name, page) do
    total = Queue.count_enqueued_jobs(config, name)

    items =
      Queue.list_enqueued_jobs(config, name, offset: @page_size * (page - 1), size: @page_size)

    %{items: items, name: name, total: total, current_page: page, page_size: @page_size}
  end
end
