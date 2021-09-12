defmodule ExqUI.Queue do
  alias Exq.Api

  defmodule JobItem do
    defstruct [:job, :id, :raw, :score, :scheduled_at]
  end

  @api Exq.Api

  def stats() do
    {:ok, queues} = Api.queue_size(@api)
    enqueued = Enum.reduce(queues, 0, fn {_name, count}, sum -> count + sum end)
    {:ok, busy} = Api.busy(@api)
    {:ok, retries} = Api.retry_size(@api)
    {:ok, scheduled} = Api.scheduled_size(@api)
    {:ok, dead} = Api.failed_size(@api)

    %{
      enqueued: enqueued,
      busy: busy,
      retries: retries,
      scheduled: scheduled,
      dead: dead
    }
  end

  def list_queues() do
    {:ok, queues} = Api.queue_size(@api)
    Enum.map(queues, fn {name, count} -> %{name: name, count: count} end)
  end

  def remove_queue(name) do
    Api.remove_queue(@api, name)
  end

  def count_enqueued_jobs(name) do
    {:ok, total} = Api.queue_size(@api, name)
    total
  end

  def list_enqueued_jobs(name, options \\ []) do
    {:ok, raw_jobs} = Api.jobs(@api, name, Keyword.merge([raw: true], options))

    items =
      Enum.map(raw_jobs, fn json ->
        job = Exq.Support.Job.decode(json)
        %JobItem{job: job, id: job.jid, raw: json}
      end)

    items
  end

  def remove_enqueued_jobs(name, raw_jobs) do
    if Enum.empty?(raw_jobs) do
      :ok
    else
      Api.remove_enqueued_jobs(@api, name, raw_jobs)
    end
  end

  def count_retry_jobs() do
    {:ok, total} = Api.retry_size(@api)
    total
  end

  def remove_retry_jobs(raw_jobs) do
    if Enum.empty?(raw_jobs) do
      :ok
    else
      Api.remove_retry_jobs(@api, raw_jobs)
    end
  end

  def remove_all_retry_jobs() do
    Api.clear_retries(@api)
  end

  def list_retry_jobs(options \\ []) do
    {:ok, jobs} = Api.retries(@api, Keyword.merge([score: true, raw: true], options))
    decode_jobs_with_score(jobs)
  end

  def find_retry_job(score, jid) do
    {:ok, json} = Api.find_retry(@api, score, jid, raw: true)

    if json do
      job_with_score(json, score)
    end
  end

  def count_scheduled_jobs() do
    {:ok, total} = Api.scheduled_size(@api)
    total
  end

  def remove_scheduled_jobs(raw_jobs) do
    if Enum.empty?(raw_jobs) do
      :ok
    else
      Api.remove_scheduled_jobs(@api, raw_jobs)
    end
  end

  def remove_all_scheduled_jobs() do
    Api.clear_scheduled(@api)
  end

  def list_scheduled_jobs(options \\ []) do
    {:ok, jobs} = Api.scheduled(@api, Keyword.merge([score: true, raw: true], options))
    decode_jobs_with_score(jobs)
  end

  def find_scheduled_job(score, jid) do
    {:ok, json} = Api.find_scheduled(@api, score, jid, raw: true)

    if json do
      job_with_score(json, score)
    end
  end

  def count_dead_jobs() do
    {:ok, total} = Api.failed_size(@api)
    total
  end

  def remove_dead_jobs(raw_jobs) do
    if Enum.empty?(raw_jobs) do
      :ok
    else
      Api.remove_failed_jobs(@api, raw_jobs)
    end
  end

  def remove_all_dead_jobs() do
    Api.clear_failed(@api)
  end

  def list_dead_jobs(options \\ []) do
    {:ok, jobs} = Api.failed(@api, Keyword.merge([score: true, raw: true], options))
    decode_jobs_with_score(jobs)
  end

  def find_dead_job(score, jid) do
    {:ok, json} = Api.find_failed(@api, score, jid, raw: true)

    if json do
      job_with_score(json, score)
    end
  end

  defp decode_jobs_with_score(jobs) do
    Enum.map(jobs, fn {json, score} ->
      job_with_score(json, score)
    end)
  end

  defp job_with_score(json, score) do
    {epoch, ""} = Float.parse(score)
    scheduled_at = DateTime.from_unix!(round(epoch))
    job = Exq.Support.Job.decode(json)
    %JobItem{raw: json, id: job.jid, job: job, score: score, scheduled_at: scheduled_at}
  end
end
