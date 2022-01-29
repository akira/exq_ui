defmodule ExqUIWeb.Helpers do
  @moduledoc false
  use Phoenix.HTML
  import Phoenix.LiveView.Helpers

  def nav_link(socket, name, link) do
    active =
      if String.contains?(Atom.to_string(socket.view), String.slice(name, 0..3)) do
        " active"
      else
        ""
      end

    live_redirect(name, to: link, class: "nav-link" <> active)
  end

  def human_time(nil) do
    ""
  end

  def human_time(epoch) when is_number(epoch) do
    DateTime.from_unix!(round(epoch))
  end

  def date_selector_class(current, days) do
    if current == days do
      "btn-primary"
    else
      "btn-outline-primary"
    end
  end
end
