defmodule ExqUi.RouterPlug do
  require Logger
  require EEx
  alias ExqUi.RouterPlug.Router

  def init(options) do
    enq_opts =
      if options[:exq_opts] do
        options[:exq_opts]
      else
        [name: Exq.Api.Server.server_name(nil)]
      end
    Keyword.put(options, :exq_opts, enq_opts)
  end

  def call(conn, opts) do
    namespace_opt = opts[:namespace] || "exq"
    conn = Plug.Conn.assign(conn, :namespace, namespace_opt)
    conn = Plug.Conn.assign(conn, :exq_name, opts[:exq_opts][:name])
    case namespace_opt do
      "" ->
        Router.call(conn, Router.init(opts))
      _ ->
        namespace(conn, opts, namespace_opt)
    end
  end

  def namespace(%Plug.Conn{path_info: [ns | path]} = conn, opts, ns) do
    Router.call(%Plug.Conn{conn | path_info: path}, Router.init(opts))
  end

  def namespace(conn, _opts, _ns), do: conn

  defmodule Router do
    import Plug.Conn
    use Plug.Router

    plug Plug.Static, at: "/", from: :exq_ui
    plug JsonApi, on: "api"

    plug :match
    plug :dispatch

    get "/api/stats/all" do
      {:ok, processed} = Exq.Api.stats(conn.assigns[:exq_name], "processed")
      {:ok, failed} = Exq.Api.stats(conn.assigns[:exq_name], "failed")
      {:ok, busy} = Exq.Api.busy(conn.assigns[:exq_name])
      {:ok, scheduled} = Exq.Api.queue_size(conn.assigns[:exq_name], :scheduled)
      {:ok, retrying} = Exq.Api.queue_size(conn.assigns[:exq_name], :retry)

      {:ok, queues} = Exq.Api.queue_size(conn.assigns[:exq_name])

      queue_sizes = for {_q, size} <- queues do
        size
      end
      qtotal = "#{Enum.sum(queue_sizes)}"

      {:ok, json} = Poison.encode(%{stat: %{id: "all", processed: processed || 0, failed: failed || 0, busy: busy || 0, scheduled: scheduled || 0, retrying: retrying || 0, enqueued: qtotal}})
      conn |> send_resp(200, json) |> halt
    end

    get "/api/realtimes" do
      {:ok, failures, successes} = Exq.Api.realtime_stats(conn.assigns[:exq_name])

      f = for {date, count} <- failures do
        %{id: "f#{date}", date: date, count: count, type: "failure"}
      end

      s = for {date, count} <- successes do
        %{id: "s#{date}", date: date, count: count, type: "success"}
      end
      all = %{realtimes: f ++ s}

      {:ok, json} = Poison.encode(all)
      conn |> send_resp(200, json) |> halt
    end

    get "/api/scheduled" do
      {:ok, jobs} = Exq.Api.scheduled_with_scores(conn.assigns[:exq_name])
      {:ok, json} = Poison.encode(%{scheduled: map_score_to_jobs(jobs) })
      conn |> send_resp(200, json) |> halt
    end

    get "/api/retries" do
      {:ok, retries} = Exq.Api.retries(conn.assigns[:exq_name])
      retries = retries |> map_jid_to_id |> convert_results_to_times(:failed_at)
      {:ok, json} = Poison.encode(%{retries: retries})

      conn |> send_resp(200, json) |> halt
    end

    get "/api/failures" do
      {:ok, failures} = Exq.Api.failed(conn.assigns[:exq_name])
      failures = failures |> map_jid_to_id |> convert_results_to_times(:failed_at)
      {:ok, json} = Poison.encode(%{failures: failures})
      conn |> send_resp(200, json) |> halt
    end

    delete "/api/failures/:id" do
      :ok = Exq.Api.remove_failed(conn.assigns[:exq_name], id)
      conn |> send_resp(204, "") |> halt
    end

    delete "/api/retries/:id" do
      :ok = Exq.Api.remove_retry(conn.assigns[:exq_name], id)
      conn |> send_resp(204, "") |> halt
    end

    delete "/api/scheduled/:id" do
      :ok = Exq.Api.remove_scheduled(conn.assigns[:exq_name], id)
      conn |> send_resp(204, "") |> halt
    end

    delete "/api/failures" do
      :ok = Exq.Api.clear_failed(conn.assigns[:exq_name])
      conn |> send_resp(204, "") |> halt
    end

    delete "/api/retries" do
      :ok = Exq.Api.clear_retries(conn.assigns[:exq_name])
      conn |> send_resp(204, "") |> halt
    end

    delete "/api/scheduled" do
      :ok = Exq.Api.clear_scheduled(conn.assigns[:exq_name])
      conn |> send_resp(204, "") |> halt
    end

    post "/api/failures/:_id/retry" do
      # TODO
      conn |> send_resp(200, "") |> halt
    end

    put "/api/retries/:id" do
      :ok = Exq.Api.retry_job(conn.assigns[:exq_name], id)
      conn |> send_resp(204, "") |> halt
    end

    get "/api/processes" do
      {:ok, processes} = Exq.Api.processes(conn.assigns[:exq_name])

      process_jobs = for p <- processes do
        process = Map.delete(p, "job")
        pjob = p.job
        process = Map.put(process, :job_id, pjob["jid"])
        |> Map.put(:started_at, score_to_time(p.started_at))
        |> Map.put(:id, "#{process.host}:#{process.pid}")
        pjob = Map.put(pjob, :id, pjob["jid"])
        [process, pjob]
      end

      processes = for [process, _job] <- process_jobs, do: process
      jobs = for [_process, job] <- process_jobs, do: job

      {:ok, json} = Poison.encode(%{processes: processes, jobs: jobs})
      conn |> send_resp(200, json) |> halt
    end

    get "/api/queues" do
      {:ok, queues} = Exq.Api.queue_size(conn.assigns[:exq_name])
      job_counts = for {q, size} <- queues, do: %{id: q, size: size}
      {:ok, json} = Poison.encode(%{queues: job_counts})
      conn |> send_resp(200, json) |> halt
    end

    get "/api/queues/:id" do
      {:ok, jobs} = Exq.Api.jobs(conn.assigns[:exq_name], id)
      jobs_structs = map_jid_to_id(jobs)
      job_ids = for j <- jobs_structs, do: j[:id]
      {:ok, json} = Poison.encode(%{queue: %{id: id, job_ids: job_ids, partial: false}, jobs: map_jid_to_id(jobs)})
      conn |> send_resp(200, json) |> halt
    end

    delete "/api/queues/:id" do
      Exq.Api.remove_queue(conn.assigns[:exq_name], id)
      conn |> send_resp(204, "") |> halt
    end

    delete "/api/processes" do
      :ok = Exq.Api.clear_processes(conn.assigns[:exq_name])
      conn |> send_resp(204, "") |> halt
    end

    # precompile index.html into render_index/1 function
    index_path = Path.join([Application.app_dir(:exq_ui), "priv/static/index.html"])
    EEx.function_from_file :defp, :render_index, index_path, [:assigns]

    match _ do
      base = ""
      if conn.assigns[:namespace] != "" do
        base = "#{conn.assigns[:namespace]}/"
      end

      conn
        |> put_resp_header("content-type", "text/html")
        |> send_resp(200, render_index(base: base))
        |> halt
    end

    def map_jid_to_id(jobs) do
      for job <- jobs do
        Map.put(job, :id, job.jid)
      end
    end

    def convert_results_to_times(jobs, score_key) do
      for job <- jobs do
        Map.put(job, score_key, score_to_time(Map.get(job, score_key)))
      end
    end

    def score_to_time(score) when is_float(score) do
      date = round(score * 1_000_000)
      |> DateTime.from_unix!(:microseconds)
      |> DateTime.to_iso8601
      date
    end

    def score_to_time(score) do
      score_to_time(String.to_float(score))
    end

    def map_score_to_jobs(jobs) do
      Enum.map(jobs, fn {job,score} ->
        job
        |> Map.put(:scheduled_at, score_to_time(score))
        |> Map.put(:id, job.jid)
      end)
    end
  end
end
