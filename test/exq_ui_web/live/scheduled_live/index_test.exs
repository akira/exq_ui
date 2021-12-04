defmodule ExqUIWeb.ScheduledLive.IndexTest do
  use ExqUI.ConnCase

  test "/scheduled", %{conn: conn} do
    {:ok, view, _} = live(conn, "/scheduled")
    html = render(view)

    assert html =~ ~r/Hardworker.*864/
    assert html =~ ~r/Hardworker.*509/
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
    assert html =~ ~r/Hardworker.*864/
    refute html =~ ~r/Hardworker.*509/
  end
end
