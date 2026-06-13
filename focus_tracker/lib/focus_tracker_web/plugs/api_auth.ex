defmodule FocusTrackerWeb.Plugs.ApiAuth do
  @moduledoc """
  Plug pipeline for JSON API routes.
  Validates Bearer JWT token from Authorization header.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :focus_tracker,
    module: FocusTracker.Guardian,
    error_handler: FocusTrackerWeb.Plugs.ApiAuthError

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
