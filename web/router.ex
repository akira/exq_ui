defmodule ExqUi.RouterPlug do
  require Logger
  require EEx
  alias ExqUi.RouterPlug.Router

  def init(options) do
    enq_opts =
      if options[:exq_opts] do
        options[:exq_opts]
      else
        [name: Exq.Api.Server.server_name(ExqUi)]
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

    plug Plug.Static, at: "/", from: :gh_exq_ui
    plug ExqUi.JsonApi, on: "api"

    plug :match
    plug :dispatch

    get "/api/stats/all" do
      {:ok, processed} = Exq.Api.stats(conn.assigns[:exq_name], "processed")
      {:ok, failed} = Exq.Api.stats(conn.assigns[:exq_name], "failed")
      {:ok, busy} = Exq.Api.busy(conn.assigns[:exq_name])
      {:ok, scheduled} = Exq.Api.scheduled_size(conn.assigns[:exq_name])
      {:ok, retrying} = Exq.Api.retry_size(conn.assigns[:exq_name])
      {:ok, dead} = Exq.Api.failed_size(conn.assigns[:exq_name])

      {:ok, queues} = Exq.Api.queue_size(conn.assigns[:exq_name])

      queue_sizes = for {_q, size} <- queues do
        size
      end
      qtotal = "#{Enum.sum(queue_sizes)}"

      {:ok, json} = Poison.encode(%{stat: %{id: "all", processed: processed || 0, failed: failed || 0,
        busy: busy || 0, scheduled: scheduled || 0, dead: dead || 0, retrying: retrying || 0, enqueued: qtotal}})
      conn |> send_resp(200, json) |> halt
    end

    get "/api/realtimes" do
      {:ok, failures, successes} = Exq.Api.realtime_stats(conn.assigns[:exq_name])

      f = for {date, count} <- failures do
        %{id: "f#{date}", timestamp: date, count: count}
      end

      s = for {date, count} <- successes do
        %{id: "s#{date}", timestamp: date, count: count}
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

    get "/api/retries/:id" do
      {:ok, retry} = Exq.Api.find_retry(conn.assigns[:exq_name], id)
      retry = retry |> map_jid_to_id |> convert_results_to_times(:failed_at)
      {:ok, json} = Poison.encode(%{retry: retry})

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

      process_jobs =
        for p <- processes do
          process = Map.delete(p, :job)
          pjob = Jason.decode!(p.job, keys: :atoms)

          process =
            Map.put(process, :job_id, pjob.jid)
            |> Map.put(:started_at, score_to_time(p.started_at))
            |> Map.put(:id, "#{process.host}:#{process.pid}")

          pjob = Map.merge(pjob, %{id: pjob.jid, args: safe_json_encode(pjob.args)})
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
    index_path = Path.join([Application.app_dir(:gh_exq_ui), "priv/static/index.html"])
    EEx.function_from_file :defp, :render_index, index_path, [:assigns]

    match _ do
      base = case conn.assigns[:namespace] do
        "" -> ""
        namespace -> "#{namespace}/"
      end

      conn
        |> put_resp_header("content-type", "text/html")
        |> send_resp(200, render_index(base: base))
        |> halt
    end

    def map_jid_to_id(jobs) when is_list(jobs) do
      for job <- jobs do
        map_jid_to_id(job)
      end
    end
    def map_jid_to_id(job), do: Map.put(job, :id, job.jid)

    def convert_results_to_times(jobs, score_key) when is_list(jobs) do
      for job <- jobs do
        convert_results_to_times(job, score_key)
      end
    end
    def convert_results_to_times(job, score_key) do
      Map.put(job, score_key, score_to_time(Map.get(job, score_key)))
    end

    def score_to_time(score) when is_float(score) do
      round(score * 1_000_000)
      |> DateTime.from_unix!(:microseconds)
      |> DateTime.to_iso8601
    end

    def score_to_time(score) do
      if String.contains?(score, ".") do
        score_to_time(String.to_float(score))
      else
        String.to_integer(score)
        |> DateTime.from_unix!
        |> DateTime.to_iso8601
      end
    end

    def map_score_to_jobs(jobs) do
      Enum.map(jobs, fn {job, score} ->
        Map.merge(
          job,
          %{
            id: job.jid,
            scheduled_at: score_to_time(score),
            args: safe_json_encode(job.args)
          }
        )
      end)
    end

    def safe_json_encode(data) do
      Jason.encode!(data)
    rescue
      _ -> data
    end
  end
end
