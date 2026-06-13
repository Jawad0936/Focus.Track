defmodule FocusTracker.Notifications.Dispatcher do
  @moduledoc """
  Delivers notifications to users via Phoenix.PubSub (web LiveView)
  and persists them to the notifications table.
  """

  require Logger
  import Ecto.Query

  alias FocusTracker.Repo
  alias FocusTracker.Notifications.Notification

  @doc """
  Send a notification for an activity.
  Persists to DB and broadcasts via PubSub to the user's topic.
  """
  def send(activity, type, message) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    result =
      %Notification{}
      |> Notification.changeset(%{
        user_id:     activity.user_id,
        activity_id: activity.id,
        type:        to_string(type),
        message:     message,
        sent_at:     now
      })
      |> Repo.insert()

    case result do
      {:ok, notification} ->
        Phoenix.PubSub.broadcast(
          FocusTracker.PubSub,
          user_topic(activity.user_id),
          {:notification, %{
            id:          notification.id,
            type:        type,
            message:     message,
            activity_id: activity.id,
            sent_at:     now
          }}
        )

        Logger.info("[Dispatcher] Sent #{type} notification to user #{activity.user_id}: #{message}")
        {:ok, notification}

      {:error, changeset} ->
        Logger.error("[Dispatcher] Failed to persist notification: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  @doc "Get last notification sent for a specific activity"
  def last_sent_at(activity_id) do
    Notification
    |> where([n], n.activity_id == ^activity_id)
    |> order_by([n], desc: n.sent_at)
    |> limit(1)
    |> select([n], n.sent_at)
    |> Repo.one()
  end

  @doc "List recent notifications for a user (for the web bell icon)"
  def list_for_user(user_id, limit \\ 20) do
    Notification
    |> where([n], n.user_id == ^user_id)
    |> order_by([n], desc: n.sent_at)
    |> limit(^limit)
    |> Repo.all()
  end

  def user_topic(user_id), do: "notifications:#{user_id}"
end
