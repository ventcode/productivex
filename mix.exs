defmodule Productive.MixProject do
  use Mix.Project

  def project do
    [
      app: :productive,
      version: "0.8.1",
      description: "Elixir client for the Productive REST API",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.4 or ~> 0.6 or ~> 0.7"},
      {:plug, "~> 1.18", only: :test}
    ]
  end
end
