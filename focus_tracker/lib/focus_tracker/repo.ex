defmodule FocusTracker.Repo do
  use Ecto.Repo,
    otp_app: :focus_tracker,
    adapter: Ecto.Adapters.Postgres
end
