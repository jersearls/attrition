defmodule Attrition.MixProject do
  use Mix.Project

  def project do
    [
      app: :attrition,
      version: "0.0.1",
      elixir: "~> 1.9",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp description do
    """
    Attrition provides the ability to display specific data HTML attributes
    based on the configuration of your mix environment.
    """
  end

  defp package do
    [
      name: :attrition,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jeremy Searls, searls@me.com"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jersearls/attrition"}
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
