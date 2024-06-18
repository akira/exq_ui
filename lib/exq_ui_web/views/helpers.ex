defmodule ExqUIWeb.Helpers do
  @moduledoc false

  use PhoenixHTMLHelpers
  import Phoenix.Component

  def nav_link(socket, name, link) do
    active =
      if String.contains?(Atom.to_string(socket.view), String.slice(name, 0..3)) do
        " active"
      else
        ""
      end

    assigns = %{to: link, class: "nav-link" <> active, name: name}

    ~H|<.link navigate={@to} class={@class}><%= @name %></.link>|
  end

  def live_link(text, options) do
    assigns = %{
      to: Keyword.fetch!(options, :to),
      class: Keyword.get(options, :class, ""),
      text: text
    }

    ~H|<.link navigate={@to} class={@class}><%= @text %></.link>|
  end

  def human_time(nil) do
    ""
  end

  def human_time(%DateTime{} = timestamp) do
    formatted = DateTime.to_iso8601(timestamp)

    content_tag(:span, formatted,
      "phx-hook": "Timestamp",
      id: "timestamp-#{:erlang.unique_integer()}",
      title: formatted
    )
  end

  def human_time(epoch) when is_number(epoch) do
    human_time(DateTime.from_unix!(round(epoch)))
  end

  def date_selector_class(current, days) do
    if current == days do
      "btn-primary"
    else
      "btn-outline-primary"
    end
  end
end
