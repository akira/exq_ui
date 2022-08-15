defmodule ExqUIWeb.RecurringLive.IndexTest do
  use ExqUI.ConnCase

  test "/recurring", %{conn: conn} do
    {:ok, view, _} = live(conn, "/recurring")
    html = render(view)

    assert html =~ ~r/hard_worker/
    assert html =~ ~r/soft_worker/
  end

  test "disable/enable", %{conn: conn} do
    {:ok, view, _} = live(conn, "/recurring")

    html = render(view)

    assert html =~
             ~S(<input id="schedule-hard_worker_enabled" name="active[enabled]" type="hidden" value="false"/>)

    html =
      element(view, "#schedule-hard_worker")
      |> render_change(%{"_target" => ["active", "toggle"]})

    assert html =~
             ~S(<input id="schedule-hard_worker_enabled" name="active[enabled]" type="hidden" value="true"/>)

    html =
      element(view, "#schedule-hard_worker")
      |> render_change(%{"_target" => ["active", "toggle"]})

    assert html =~
             ~S(<input id="schedule-hard_worker_enabled" name="active[enabled]" type="hidden" value="false"/>)
  end

  test "enqueue now", %{conn: conn} do
    {:ok, view, _} = live(conn, "/recurring")

    element(view, "main table tbody tr:nth-child(1) a", "Enqueue Now")
    |> render_click()

    {:ok, view, _} = live(conn, "/queues")

    {:ok, view, _} =
      element(view, "main > table > tbody > tr > td:nth-child(1) > span > a", "hard")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    assert html =~ ~r/Hardworker.*435493/
  end
end
