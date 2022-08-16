defmodule ExqUIWeb.BusyLive.IndexTest do
  use ExqUI.ConnCase

  test "/busy", %{conn: conn} do
    {:ok, view, _} = live(conn, "/busy")
    html = render(view)

    assert html =~ ~r/Queues:.*hard, soft/
    assert html =~ ~r/790fa550-08a4-42de-93e4-8c09c867befe/
    assert html =~ ~r/0aec2714-9032-4574-ae45-a2037c874d9f/
  end

  test "quiet", %{conn: conn} do
    {:ok, view, _} = live(conn, "/busy")

    html = render(view)
    refute html =~ ~S(disabled="disabled")

    html =
      element(view, "#node-anantha-ubuntu")
      |> render_change(%{"_target" => ["signal", "quiet"]})

    assert html =~ ~S(disabled="disabled")
  end
end
