defmodule ExqUIWeb.RetryLive do
  use ExqUIWeb, :live_view
  alias Exq.Api

  @page_size 30

  @impl true
  def mount(params, _session, socket) do
    socket =
      assign(socket, :columns, [
        %{header: "Next Retry", accessor: fn item -> item.scheduled_at end},
        %{header: "Retry Count", accessor: fn item -> item.job.retry_count end},
        %{header: "Queue", accessor: fn item -> item.job.queue end},
        %{header: "Module", accessor: fn item -> item.job.class end},
        %{header: "Arguments", accessor: fn item -> inspect(item.job.args) end},
        %{header: "Error", accessor: fn item -> item.job.error_message end}
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
      |> push_patch(to: Routes.retry_path(socket, :index, page: page))

    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete"} = params}, socket) do
    raw_jobs =
      Map.delete(params, "action")
      |> Map.values()

    unless Enum.empty?(raw_jobs) do
      :ok = Api.remove_retry_jobs(Exq.Api, raw_jobs)
    end

    socket = assign(socket, jobs_details(socket.assigns.current_page || "1"))
    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"table" => %{"action" => "delete_all"}}, socket) do
    :ok = Api.clear_retries(Exq.Api)
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
    {:ok, total} = Api.retry_size(Exq.Api)

    {:ok, jobs} =
      Api.retries(Exq.Api,
        score: true,
        offset: @page_size * (page - 1),
        size: @page_size,
        raw: true
      )

    items =
      Enum.map(jobs, fn {json, score} ->
        {epoch, ""} = Float.parse(score)
        scheduled_at = DateTime.from_unix!(round(epoch))
        job = Exq.Support.Job.decode(json)
        %{raw: json, id: job.jid, job: job, score: score, scheduled_at: scheduled_at}
      end)

    %{items: items, total: total, current_page: page, page_size: @page_size}
  end
end
