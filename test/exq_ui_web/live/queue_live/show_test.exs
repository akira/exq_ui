defmodule ExqUIWeb.QueueLive.ShowTest do
  use ExqUI.ConnCase

  test "/queues/hard", %{conn: conn} do
    {:ok, view, _} = live(conn, "/queues/hard")
    html = render(view)

    assert html =~ ~r/Hardworker.*428/
  end

  test "delete_all", %{conn: conn} do
    {:ok, view, _} = live(conn, "/queues/hard")

    html =
      element(
        view,
        "#table-component"
      )
      |> render_hook("action", %{"table" => %{"action" => "delete_all"}})

    refute html =~ ~r/Hardworker.*428/
  end

  test "delete", %{conn: conn} do
    {:ok, view, _} = live(conn, "/queues/hard")

    html =
      element(
        view,
        "#table-component"
      )
      |> render_hook("action", %{
        "table" => %{
          "24b09253-1bbe-4d8a-804a-582d3541d31b" =>
            "{\"args\":[428],\"class\":\"Hardworker\",\"enqueued_at\":1638553683.274524,\"jid\":\"24b09253-1bbe-4d8a-804a-582d3541d31b\",\"queue\":\"hard\",\"retry\":3}",
          "action" => "delete"
        }
      })

    refute html =~ ~r/Hardworker.*428/
  end
end
