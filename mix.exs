defmodule ExqUi.Mixfile do
  use Mix.Project

  def project do
    [ app: :gh_exq_ui,
      version: "0.12.0",
      elixir: "~> 1.3",
      elixirc_paths: ["lib", "web"],
      package: [
        maintainers: ["Alex Kira", "Justin McNally", "Nick Sanders"],
        links: %{"GitHub" => "https://github.com/GeminiHealthLLC/exq_ui"},
        licenses: ["Apache2.0"],
        files: ~w(lib priv test web) ++
               ~w(LICENSE mix.exs README.md)
      ],
      description: """
      Exq UI is the UI component for Exq, a job processing library.  Exq UI provides the UI dashboard
      to display stats on job processing.
      """,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { ExqUi, [] },
      applications: [:redix],
      extra_applications: [:plug, :logger]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      { :exq, ">= 0.9.0"},
      { :poison, ">= 1.2.0 or ~> 2.0"}, # Take out after #83
      { :excoveralls, "~> 0.3", only: :test },
      { :ex_doc, "~> 0.19", only: :dev }
    ] ++ cowboy_deps()
  end

  def cowboy_deps do
    case otp_version() >= 19 && minor_elixir_version() >= 4 do
      true -> [
          { :plug, "~> 1.6"},
          { :cowboy, "~> 2.4" }
      ]
      _ -> [
          { :plug, "< 1.0.3" },
          { :cowboy, "~> 1.0" }
      ]
    end
  end

  # elixir/otp version helpers
  def minor_elixir_version do
    {_, version} = Version.parse(System.version)
    version.minor
  end

  def otp_version do
    :erlang.system_info(:otp_release)
    |> to_string()
    |> String.to_integer()
  end
end
