# ExqUi

[![Travis Build Status](https://img.shields.io/travis/akira/exq_ui.svg)](https://travis-ci.org/akira/exq_ui)
[![Coveralls Coverage](https://img.shields.io/coveralls/akira/exq_ui.svg)](https://coveralls.io/github/akira/exq_ui)
[![Hex.pm Version](https://img.shields.io/hexpm/v/exq_ui.svg)](https://hex.pm/packages/exq_ui)

ExqUI provides a UI dashboard for [Exq](https://github.com/akira/exq), a job processing library compatible with Resque / Sidekiq for the [Elixir](http://elixir-lang.org) language.
ExqUI allow you to see various job processing stats, as well as details on failed, retried, scheduled jobs, etc.


## Getting Started:

See [Exq](https://github.com/akira/exq) for using the Exq library.
This assumes you have an instance of [Redis](http://redis.io/).

### Installation:
Add exq_ui to your mix.exs deps (replace version with the latest hex.pm package version):

```elixir
  defp deps do
    [
      # ... other deps
      {:exq_ui, "~> 0.8.2"}
    ]
  end
```

Then run ```mix deps.get```.

For Elixir 1.2 or older, you will need to use Exq version 0.7.2 in hex, and you will also need to add `:tzdata` to your application list.

### Configuration:

By default, Exq will use configuration from your config.exs file.  You can use this
to configure your Redis host, port, password, as well as namespace (which helps isolate the data in Redis).

```elixir
config :exq,
  host: "127.0.0.1",
  port: 6379,
  password: "optional_redis_auth",
  namespace: "exq",
  concurrency: :infinite,
  queues: ["default"],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 25
```

There are also a few configuration options for the UI:
```elixir
config :exq_ui,
  webport: 4040,
  web_namespace: "",
  server: true
```

The webport configures which port to start the UI on, and the web_namespace configures what to use as the application root
(both when using `mix exq.ui`).

By default the empty namespace is used, so you can access the UI via:  `http://localhost:4040/`.

When setting a different web_namespace, for example `exq_ui`, you can access the UI via: `http://localhost:4040/exq_ui`.

The `server` option allows you to refrain from starting the web server during tests. It is set to `true` by default.

## Web UI:

This is a screenshot of the UI Dashboard provided by Exq UI:
![Screenshot](http://i.imgur.com/m57gRPY.png)

To start the web UI:
```
> mix exq.ui
```

## Using with Plug

To use this with Plug, edit your router.ex and add this section:

```elixir
...

  pipeline :exq do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug ExqUi.RouterPlug, namespace: "exq"
  end

  scope "/exq", ExqUi do
    pipe_through :exq
    forward "/", RouterPlug.Router, :index
  end
```

## Questions?  Issues?

For issues, please submit a Github issue with steps on how to reproduce the problem.

For questions, stop in at the [#elixir-lang Slack group](https://elixir-slackin.herokuapp.com/)


## Contributions

Contributions are welcome. Tests are encouraged.

By default, a static distribution of the UI is used.
To run the UI and automatically build the JS distribution on changes, run:

```
> cd priv/ember
> npm install
> bower install
> ./node_modules/ember-cli/bin/ember server
```

To run tests / ensure your changes have not caused any regressions:

```
mix test --no-start
```

## Contributors:

Justin McNally (j-mcnally) (structtv)

Nick Sanders (nicksanders)

Nick Gal (nickgal)

pdilyard (Paul Dilyard)

Alexander Shapiotko (thousandsofthem)
