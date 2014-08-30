defmodule Defpool.Mixfile do
  use Mix.Project

  def project do
    [app: :defpool,
     version: "0.0.1",
     elixir: "~> 0.15.0",
     deps: deps]
  end

  def application do
    [applications: [ :pooler ] ]
  end

  defp deps do
    [ {:pooler, github: "seth/pooler", tag: "1.1.0"},
      {:meck, "~> 0.8.2", only: :test} ]
  end
end
