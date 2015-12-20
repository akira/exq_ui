# ExqUi

[![Travis Build Status](https://img.shields.io/travis/akira/exq.svg)](https://travis-ci.org/akira/exq)
[![Coveralls Coverage](https://img.shields.io/coveralls/akira/exq.svg)](https://coveralls.io/github/akira/exq)
[![Hex.pm Version](https://img.shields.io/hexpm/v/exq.svg)](https://hex.pm/packages/exq)

ExqUI provides a UI dashboard for Exq, a job processing library compatible with Resque / Sidekiq for the [Elixir](http://elixir-lang.org) language.


## Getting Started:

See [Exq](https://github.com/akira/exq_ui) for using the Exq library.
This assumes you have an instance of [Redis](http://redis.io/) to use and you have already used Exq.

### Installation:
Add exq_ui to your mix.exs deps (replace version with the latest hex.pm package version):

```elixir
  defp deps do
    [
      # ... other deps
      {:exq_ui, "~> 0.5.0"}
    ]
  end
```

Then run ```mix deps.get```.

### Configuration:

By default, Exq will use configuration from your config.exs file.  You can use this
to configure your Redis host, port, password, as well as namespace (which helps isolate the data in Redis).
The "concurrency" setting will let you configure the amount of concurrent workers that will be allowed, or :infinite to disable any throttling.

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


## Web UI:

This is a screenshot of the UI Dashboard provided by Exq UI:
![Screenshot](http://i.imgur.com/m57gRPY.png)

To start the web UI:
```
> mix exq.ui
```

You can also use [Plug](https://github.com/elixir-lang/plug) to connect the web UI to your Web application.

## Contributions

Contributions are welcome. Tests are encouraged.

To run tests / ensure your changes have not caused any regressions:

```
redis-server --port 6555
mix test
```

## Contributors:

Justin McNally (j-mcnally) (structtv)

Nick Sanders (nicksanders)

Nick Gal (nickgal)