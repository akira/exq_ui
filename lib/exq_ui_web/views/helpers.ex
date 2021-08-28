defmodule ExqUIWeb.Helpers do
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
end
