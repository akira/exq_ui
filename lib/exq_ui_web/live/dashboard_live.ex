defmodule ExqUIWeb.DashboardLive do
  use ExqUIWeb, :live_view

  alias Exq.Api

  @tick_interval 10000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :tick, @tick_interval)

    {:ok, assign(socket, stats: stats())}
  end

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @tick_interval)
    {:noreply, assign(socket, :stats, stats())}
  end

  defp stats() do
    {:ok, queues} = Api.queue_size(Exq.Api)
    enqueued = Enum.reduce(queues, 0, fn {_name, count}, sum -> count + sum end)
    {:ok, busy} = Api.busy(Exq.Api)
    {:ok, retries} = Api.retry_size(Exq.Api)
    {:ok, scheduled} = Api.scheduled_size(Exq.Api)
    {:ok, dead} = Api.failed_size(Exq.Api)

    %{
      enqueued: enqueued,
      busy: busy,
      retries: retries,
      scheduled: scheduled,
      dead: dead
    }
  end
end
