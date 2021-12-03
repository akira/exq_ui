defmodule ExqUIWeb.QueueLive.IndexTest do
  use ExqUI.ConnCase

  test "/queues", %{conn: conn} do
    {:ok, view, _} = live(conn, "/queues")
    html = render(view)

    assert html =~ ~r/hard.*1.*Delete/

    html =
      element(
        view,
        "main > table > tbody > tr > td:nth-child(3) > span > a",
        "Delete"
      )
      |> render_click()

    refute html =~ ~r/hard.*1.*Delete/
  end
end
