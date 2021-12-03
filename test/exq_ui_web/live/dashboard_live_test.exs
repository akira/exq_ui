defmodule ExqUIWeb.DashboardLiveTest do
  use ExqUI.ConnCase

  test "/", %{conn: conn} do
    {:ok, view, _} = live(conn, "/")
    html = render(view)

    assert html =~ ~r/5456.*Processed/
    assert html =~ ~r/4949.*Failed/
    assert html =~ ~r/1.*Enqueued/
    assert html =~ ~r/1.*Scheduled/
  end
end
