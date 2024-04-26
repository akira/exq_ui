defmodule ExqUI.MixProject do
  use Mix.Project

  @version "0.15.0"

  def project do
    [
      app: :exq_ui,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      docs: docs(),
      deps: deps(),
      package: package(),
      test_coverage: [
        ignore_modules: [ExqUI.Queue.JobItem, ExqUIWeb, ExqUIWeb.ErrorView, ExqUIWeb.Router],
        summary: [threshold: 80]
      ]
    ]
  end

  def application do
    [
      mod: {ExqUI.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:exq, ">= 0.16.2"},
      {:exq_scheduler, "~> 1.0", optional: true},
      {:phoenix_live_view, "~> 0.18"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:redix, ">= 0.9.0"},
      {:floki, ">= 0.30.0", only: :test},
      # docs
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: """
      Exq UI is the UI component for Exq, a job processing library.  Exq UI provides the UI dashboard
      to display stats on job processing.
      """,
      maintainers: ["Anantha Kumaran", "Alex Kira"],
      links: %{"GitHub" => "https://github.com/akira/exq_ui"},
      licenses: ["Apache2.0"],
      files:
        ~w(lib priv test assets/js assets/css assets/static) ++
          ~w(LICENSE mix.exs README.md CHANGELOG.md)
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"],
      dev: "run --no-halt dev.exs"
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md"],
      main: "readme",
      formatters: ["html"],
      source_url: "https://github.com/akira/exq_ui",
      source_ref: "v#{@version}"
    ]
  end
end
