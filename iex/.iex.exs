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
