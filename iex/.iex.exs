IEx.configure(
  inspect: [limit: :infinity, printable_limit: :infinity, pretty: true],
  history_size: 1_000,
  width: 100,
  colors: [
    ls_directory: :light_cyan
  ]
)

now = fn -> DateTime.utc_now() end
now_iso = fn -> DateTime.utc_now() |> DateTime.to_iso8601() end

defmodule Dep do
  for {name, _ver} = dep <- [
        {:decimal, "~> 2.1"},
        {:uuid, "~> 1.1"},
        {:timex, "~> 3.7"},
        {:csv, "~> 3.2"},
        {:jason, "~> 1.4"},
        {:httpoison, "~> 2.1"},
        {:finch, "~> 0.16.0"},
        {:neuron, "~> 5.1"},
        {:observer_cli, "~> 1.7"},
        {:recon, "~> 2.5"}
      ] do
    def unquote(name)(), do: unquote(dep)
    def unquote(:"install_#{name}")(), do: install([unquote(dep)])
  end

  def install(deps), do: deps |> List.wrap() |> Mix.install()
end
