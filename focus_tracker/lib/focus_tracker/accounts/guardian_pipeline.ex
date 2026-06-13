defmodule FocusTracker.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :focus_tracker,
    module: FocusTracker.Guardian,
    error_handler: FocusTracker.Guardian.ErrorHandler

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
