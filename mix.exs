defmodule Notary.MixProject do
  use Mix.Project

  def project do
    [
      app: :notary,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Notary.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.2"},
      {:postgrex, "~> 0.15"},
      {:grpc, "~> 0.7"},
      {:protobuf, "~> 0.11"},
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4.0"},
      {:joken, "~> 2.5"},
      {:req, "~> 0.4.9"},
      {:dotenvy, "~> 0.8.0"},
      {:cors_plug, "~> 3.0"},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
