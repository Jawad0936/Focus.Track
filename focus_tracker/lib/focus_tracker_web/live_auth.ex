defmodule FocusTrackerWeb.LiveAuth do
  import Phoenix.Component, only: [assign: 3]

  alias FocusTracker.Guardian

  def on_mount(:require_authenticated, _params, session, socket) do
    case session["guardian_default_token"] do
      nil ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/auth/google")}

      token ->
        case Guardian.decode_and_verify(token) do
          {:ok, claims} ->
            {:ok, user} = Guardian.resource_from_claims(claims)
            {:cont, assign(socket, :current_user, user)}

          _ ->
            {:halt, Phoenix.LiveView.redirect(socket, to: "/auth/google")}
        end
    end
  end
end
