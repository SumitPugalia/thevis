[
  plt_add_deps: :transitive,
  plt_add_apps: [:mix, :ex_unit],
  plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
  flags: [
    :error_handling,
    :underspecs,
    :unknown,
    :unmatched_returns
  ],
  paths: [
    "_build/dev/lib/thevis/ebin",
    "_build/test/lib/thevis/ebin"
  ]
]
