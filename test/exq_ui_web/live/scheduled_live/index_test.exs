defmodule ExqUIWeb.ScheduledLive.IndexTest do
  use ExqUI.ConnCase

  test "/scheduled", %{conn: conn} do
    {:ok, view, _} = live(conn, "/scheduled")
    html = render(view)

    assert html =~ ~r/Hardworker.*864/s
    assert html =~ ~r/Hardworker.*509/s
  end

  test "view and delete single job", %{conn: conn} do
    {:ok, view, _} = live(conn, "/scheduled")

    {:ok, view, _} =
      element(view, "#scheduled-table > tbody > tr:nth-child(2) > td:nth-child(2) > a")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    assert html =~ ~r/JID.*eac6e91d-8863-4bc5-af46-d0182966e81f/

    {:ok, view, _} =
      element(view, "div.col-4.my-2 > a", "Delete")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    assert html =~ ~r/Hardworker.*864/s
    refute html =~ ~r/Hardworker.*509/s
  end

  test "delete_all", %{conn: conn} do
    {:ok, view, _} = live(conn, "/scheduled")
    html = render(view)
    assert html =~ ~r/Hardworker.*864/s
    assert html =~ ~r/Hardworker.*509/s

    element(
      view,
      "#table-component"
    )
    |> render_hook("action", %{"table" => %{"action" => "delete_all"}})

    {:ok, view, _} = live(conn, "/scheduled")
    html = render(view)
    refute html =~ ~r/Hardworker.*864/s
    refute html =~ ~r/Hardworker.*509/s
  end

  test "add to queue", %{conn: conn} do
    {:ok, view, _} = live(conn, "/scheduled")

    {:ok, view, _} =
      element(view, "#scheduled-table > tbody > tr:nth-child(2) > td:nth-child(2) > a")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    assert html =~ ~r/JID.*eac6e91d-8863-4bc5-af46-d0182966e81f/

    {:ok, view, _} =
      element(view, "div.col-4.my-2 > a:nth-child(2)", "Add to Queue")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    assert html =~ ~r/Hardworker.*864/s
    refute html =~ ~r/Hardworker.*509/s

    {:ok, view, _} = live(conn, "/queues/hard")
    html = render(view)
    assert html =~ ~r/Hardworker.*509/s
  end
end
