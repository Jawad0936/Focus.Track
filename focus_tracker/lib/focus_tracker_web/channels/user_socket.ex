defmodule FocusTrackerWeb.UserSocket do
  use Phoenix.Socket

  channel "notifications:*", FocusTrackerWeb.NotificationChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case FocusTracker.Guardian.decode_and_verify(token) do
      {:ok, _claims} -> {:ok, socket}
      {:error, _} -> :error
    end
  end

  def connect(_, _, _), do: :error

  @impl true
  def id(_socket), do: nil
end
