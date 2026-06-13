alias FocusTracker.Repo

version_str = "20260609000400"
version = String.to_integer(version_str)

case Repo.query!("SELECT 1 FROM schema_migrations WHERE version = $1", [version]) do
  %Postgrex.Result{num_rows: 0} ->
    Repo.query!("INSERT INTO schema_migrations (version) VALUES ($1)", [version])
    IO.puts("Marked migration #{version_str} as applied in schema_migrations")

  %Postgrex.Result{num_rows: n} when n > 0 ->
    IO.puts("Migration #{version_str} already recorded in schema_migrations")
end
