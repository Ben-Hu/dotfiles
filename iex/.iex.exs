IEx.configure(
  inspect: [limit: :infinity, printable_limit: :infinity, pretty: true],
  history_size: 100,
  width: 100,
  colors: [
    ls_directory: :light_cyan
  ]
)

now = fn -> DateTime.utc_now() end
now_iso = fn -> DateTime.utc_now() |> DateTime.to_iso8601() end

defmodule Dep do
  for {name, _ver} = dep <- [
        {:decimal, "~> 2.0"},
        {:uuid, "~> 1.1"},
        {:timex, "~> 3.7"},
        {:csv, "~> 2.4"},
        {:jason, "~> 1.2"},
        {:httpoison, "~> 1.8"},
        {:mojito, "~> 0.7.10"},
        {:neuron, "~> 5.0"},
        {:observer_cli, "~> 1.7"},
        {:recon, "~> 2.5"}
      ] do
    def unquote(name)(), do: unquote(dep)
    def unquote(:"install_#{name}")(), do: install([unquote(dep)])
  end

  def install(deps), do: deps |> List.wrap() |> Mix.install()
end
