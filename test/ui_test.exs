defmodule Exq.ApiTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias Exq.Support.Config
  alias Exq.Support.Job
  alias Exq.Redis.JobQueue
  alias Exq.Support.Process
  alias Exq.Redis.JobStat
  import ExqTestUtil

  setup_all do
    TestRedis.setup
    {:ok, sup} = Exq.start_link([host: redis_host, port: redis_port, name: Exq, mode: :api])
    on_exit fn ->
      TestRedis.teardown
      stop_process(sup)
    end
    :ok
  end

  defp call(conn) do
    conn
    |> assign(:exq_name, Exq.Api)
    |> ExqUi.RouterPlug.Router.call([])
 end

  test "serves the index" do
    conn = conn(:get, "/") |> call
    assert conn.status == 200
  end
  test "serves the stats" do
    conn = conn(:get, "/api/stats/all") |> call
    assert conn.status == 200
  end

  test "serves the failures" do
    conn = conn(:get, "/api/failures") |> call
    assert conn.status == 200
  end

  test "serves the failure" do
    conn = conn(:get, "/api/failures/123") |> call
    assert conn.status == 200
  end

  test "serves the realtime" do
    conn = conn(:get, "/api/realtimes") |> call
    assert conn.status == 200
  end

  test "serves the processes" do
    JobStat.add_process(:testredis, "exq", %Process{pid: self, job: %Job{jid: "1234"}, started_at: 1470539976.93175})
    conn = conn(:get, "/api/processes") |> call
    assert conn.status == 200
    {:ok, json} = Config.serializer.decode(conn.resp_body)
    assert json["processes"] != nil
  end

  test "serves the queues" do
    conn = conn(:get, "/api/queues") |> call
    assert conn.status == 200
  end

  test "serves scheduled" do
    state = :sys.get_state(Exq.Api)
    {:ok, jid} = JobQueue.enqueue_in(state.redis, state.namespace, "custom", 1000, TestWorker, [])
    conn = conn(:get, "/api/scheduled") |> call
    assert conn.status == 200

    json = Config.serializer.decode!(conn.resp_body)
    assert %{"scheduled" => [%{"scheduled_at" => _at, "jid" => ^jid}]} = json
  end

  test "serves retries" do
    state = :sys.get_state(Exq.Api)
    JobQueue.retry_job(state.redis, state.namespace, %Job{jid: "1234"}, 1, "this is an error")
    conn = conn(:get, "/api/retries") |> call
    assert conn.status == 200

    json = Config.serializer.decode!(conn.resp_body)
    assert json |> Map.get("retries") |> hd |> Map.get("jid") == "1234"
  end

  test "serves the queue" do
    conn = conn(:get, "/api/queues/default") |> call
    assert conn.status == 200
  end
end
