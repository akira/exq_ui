defmodule ExqUIWeb.RetryLive do
  use ExqUIWeb, :live_view
  alias Exq.Api

  @page_size 30

  @impl true
  def mount(params, _session, socket) do
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

  defp jobs_details(page) do
    current_page =
      case Integer.parse(page) do
        :error -> 1
        {page, _} -> page
      end

    {:ok, total} = Api.retry_size(Exq.Api)

    {:ok, jobs} =
      Api.retries(Exq.Api, score: true, offset: @page_size * (current_page - 1), size: @page_size)

    jobs =
      Enum.map(jobs, fn {job, score} ->
        {epoch, ""} = Float.parse(score)
        scheduled_at = DateTime.from_unix!(round(epoch))
        %{job: job, score: score, scheduled_at: scheduled_at}
      end)

    %{jobs: jobs, total: total, current_page: current_page, page_size: @page_size}
  end
end
