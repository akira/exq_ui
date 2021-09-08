# ExqUI

## Configuration

1) ExqUI uses Phoenix LiveView. If you already use LiveView, skip to
next step. Otherwise follow LiveView [installation docs](https://hexdocs.pm/phoenix_live_view/installation.html).

2) In your phoenix router import `ExqUIWeb.Router` and add
`live_exq_ui(path)`

```elixir
defmodule DemoWeb.Router do
  use Phoenix.Router
  import ExqUIWeb.Router

  pipeline :browser do
    plug :fetch_session
    plug :protect_from_forgery
  end

  scope "/", DemoWeb do
    pipe_through :browser

    live_exq_ui("/exq")
  end
end
```
