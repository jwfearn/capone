defmodule Capone.MixProject do
  use Mix.Project

  def project do
    [
      app: :capone,
      deps: deps(),
      elixir: "~> 1.6",
      escript: [main_module: Capone],
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:tesla, "~> 0.10"}
    ]
  end
end
