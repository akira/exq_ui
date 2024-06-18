defmodule ExqUIWeb.QueueLive.IndexTest do
  use ExqUI.ConnCase

  test "/queues", %{conn: conn} do
    {:ok, view, _} = live(conn, "/queues")
    html = render(view)

    assert html =~ ~r/hard.*1.*Delete/s

    html =
      element(
        view,
        "main > table > tbody > tr > td:nth-child(3) > span > a",
        "Delete"
      )
      |> render_click()

    refute html =~ ~r/hard.*1.*Delete/s
  end

  test "view single queue", %{conn: conn} do
    {:ok, view, _} = live(conn, "/queues")

    {:ok, view, _} =
      element(view, "main > table > tbody > tr > td:nth-child(1) > span > a", "hard")
      |> render_click()
      |> follow_redirect(conn)

    html = render(view)
    assert html =~ ~r/Hardworker.*428/
  end
end
