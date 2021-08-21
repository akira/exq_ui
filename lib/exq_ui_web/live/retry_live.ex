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

    {:ok, assign(socket, jobs_details(params["page"] || "1")) |> IO.inspect()}
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

  defp jobs_details(page) do
    current_page =
      case Integer.parse(page) do
        :error -> 1
        {page, _} -> page
      end

    {:ok, total} = Api.retry_size(Exq.Api)

    {:ok, jobs} =
      Api.retries(Exq.Api,
        score: true,
        offset: @page_size * (current_page - 1),
        size: @page_size,
        raw: true
      )

    items =
      Enum.map(jobs, fn {json, score} ->
        {epoch, ""} = Float.parse(score)
        scheduled_at = DateTime.from_unix!(round(epoch))
        %{raw: json, job: Exq.Support.Job.decode(json), score: score, scheduled_at: scheduled_at}
      end)

    %{items: items, total: total, current_page: current_page, page_size: @page_size}
  end
end
