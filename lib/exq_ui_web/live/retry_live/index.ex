defmodule ExqUIWeb.RetryLive.Index do
  @moduledoc false
  use ExqUIWeb, :live_view
  alias ExqUI.Queue

  @page_size 30

  @impl true
  def mount(params, _session, socket) do
    socket =
      assign(socket, :columns, [
        %{
          header: "Next Retry",
          link: true,
          accessor: fn item ->
            %{
              text: human_time(item.scheduled_at),
              link: Routes.retry_show_path(socket, item.score, item.id),
              class: "nounderline"
            }
          end
        },
        %{header: "Retry Count", accessor: fn item -> item.job.retry_count end},
        %{header: "Queue", accessor: fn item -> item.job.queue end},
        %{header: "Module", accessor: fn item -> item.job.class end},
        %{header: "Arguments", text_break: true, accessor: fn item -> inspect(item.job.args) end},
        %{header: "Error", text_break: true, accessor: fn item -> item.job.error_message end}
      ])
      |> assign(:actions, [
        %{name: "delete", label: "Delete"},
        %{name: "delete_all", label: "Delete All"},
        %{name: "retry_now", label: "Retry Now"}
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
      |> push_patch(to: Routes.retry_index_path(socket, page: page))

    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete"} = params}, socket) do
    raw_jobs =
      Map.delete(params, "action")
      |> Map.values()

    :ok = Queue.remove_retry_jobs(raw_jobs)

    socket = assign(socket, jobs_details(socket.assigns.current_page || "1"))
    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete_all"}}, socket) do
    :ok = Queue.remove_all_retry_jobs()
    socket = assign(socket, jobs_details(socket.assigns.current_page || "1"))
    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "retry_now"} = params}, socket) do
    raw_jobs =
      Map.delete(params, "action")
      |> Map.values()

    :ok = Queue.dequeue_retry_jobs(raw_jobs)

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
    total = Queue.count_retry_jobs()
    items = Queue.list_retry_jobs()

    %{items: items, total: total, current_page: page, page_size: @page_size}
  end
end
