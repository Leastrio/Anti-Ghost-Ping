defmodule AntiGhostPing.MixProject do
  use Mix.Project

  def project do
    [
      app: :anti_ghost_ping,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:mnesia, :logger],
      mod: {AntiGhostPing.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, github: "Leastrio/nostrum"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:nebulex, "~> 2.5"},
    ]
  end
end
