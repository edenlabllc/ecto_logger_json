defmodule EctoLoggerJson.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_logger_json,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_deps: true,
        plt_file: ".local.plt"
      ],
      description: "Overrides Ecto's LogEntry to format ecto logs as json",
      docs: [extras: ["README.md"]],
      elixir: "~> 1.6",
      homepage_url: "https://github.com/bleacherreport/ecto_logger_json",
      name: "Ecto Logger JSON",
      package: package(),
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: "https://github.com/bleacherreport/ecto_logger_json",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.1.0"
    ]
  end

  def application do
    [applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto, "~> 2.1 or ~> 3.0"},
      {:credo, "~> 0.5", only: [:dev]},
      {:dialyxir, "~> 0.4", only: [:dev]},
      {:earmark, "~> 1.0", only: [:dev]},
      {:ex_doc, "~> 0.14", only: [:dev]},
      {:excoveralls, "~> 0.6", only: [:test]},
      {:jason, "~> 1.1"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/bleacherreport/ecto_logger_json"},
      maintainers: ["John Kelly"]
    ]
  end
end
