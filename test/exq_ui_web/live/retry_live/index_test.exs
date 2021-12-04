defmodule ExqUIWeb.RetryLive.IndexTest do
  use ExqUI.ConnCase

  test "/retries", %{conn: conn} do
    {:ok, view, _} = live(conn, "/retries")
    html = render(view)

    assert html =~ ~r/hard.*499.*{:bad, :reason}/
    assert html =~ ~r/hard.*235.*RuntimeError/
  end

  test "view and delete single job", %{conn: conn} do
    {:ok, view, _} = live(conn, "/retries")

    {:ok, view, _} =
      element(view, "#retry-table > tbody > tr:nth-child(1) > td:nth-child(2) > a")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    assert html =~ ~r/JID.*537bc07e-4f22-4eb2-a0c3-9f79ca06c489/

    {:ok, view, _} =
      element(view, "div.col-4.my-2 > a", "Delete")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    refute html =~ ~r/hard.*499.*{:bad, :reason}/
    assert html =~ ~r/hard.*235.*RuntimeError/
  end
end
