defmodule FocusTrackerWeb.NotificationChannel do
  use Phoenix.Channel

  alias FocusTracker.Guardian
  alias FocusTracker.Notifications.Dispatcher

  @doc """
  Mobile joins with: channel "notifications:me", token: jwt_token
  """
  def join("notifications:me", %{"token" => token}, socket) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, user} ->
            Phoenix.PubSub.subscribe(FocusTracker.PubSub, Dispatcher.user_topic(user.id))

            socket = assign(socket, :current_user, user)
            {:ok, %{status: "connected", user_id: user.id}, socket}

          {:error, reason} ->
            {:error, %{reason: to_string(reason)}}
        end

      {:error, reason} ->
        {:error, %{reason: to_string(reason)}}
    end
  end

  def join(_, _, _socket), do: {:error, %{reason: "unauthorized"}}

  def handle_info({:notification, notif}, socket) do
    push(socket, "new_notification", %{
      id: notif.id,
      type: notif.type,
      message: notif.message,
      activity_id: notif.activity_id,
      sent_at: DateTime.to_iso8601(notif.sent_at)
    })

    {:noreply, socket}
  end
end
