defmodule ExqUIWeb.RetryLive.IndexTest do
  use ExqUI.ConnCase

  test "/retries", %{conn: conn} do
    {:ok, view, _} = live(conn, "/retries")
    html = render(view)

    assert html =~ ~r/hard.*499.*{:bad, :reason}/s
    assert html =~ ~r/hard.*235.*RuntimeError/s
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
    refute html =~ ~r/hard.*499.*{:bad, :reason}/s
    assert html =~ ~r/hard.*235.*RuntimeError/s
  end

  test "delete_all", %{conn: conn} do
    {:ok, view, _} = live(conn, "/retries")
    html = render(view)
    assert html =~ ~r/hard.*499.*{:bad, :reason}/s
    assert html =~ ~r/hard.*235.*RuntimeError/s

    element(
      view,
      "#table-component"
    )
    |> render_hook("action", %{"table" => %{"action" => "delete_all"}})

    {:ok, view, _} = live(conn, "/retries")
    html = render(view)
    refute html =~ ~r/hard.*499.*{:bad, :reason}/
    refute html =~ ~r/hard.*235.*RuntimeError/
  end

  test "retry now", %{conn: conn} do
    {:ok, view, _} = live(conn, "/retries")

    {:ok, view, _} =
      element(view, "#retry-table > tbody > tr:nth-child(1) > td:nth-child(2) > a")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    assert html =~ ~r/JID.*537bc07e-4f22-4eb2-a0c3-9f79ca06c489/

    {:ok, view, _} =
      element(view, "div.col-4.my-2 > a:nth-child(2)", "Retry Now")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    refute html =~ ~r/hard.*499.*{:bad, :reason}/s
    assert html =~ ~r/hard.*235.*RuntimeError/s

    {:ok, view, _} = live(conn, "/queues/hard")
    html = render(view)
    assert html =~ ~r/Hardworker.*499/s
  end
end
