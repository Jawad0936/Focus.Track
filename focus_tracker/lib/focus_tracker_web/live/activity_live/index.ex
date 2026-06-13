defmodule FocusTrackerWeb.ActivityLive.Index do
  use FocusTrackerWeb, :live_view
  on_mount {FocusTrackerWeb.LiveAuth, :require_authenticated}

  alias FocusTracker.Activities
  alias FocusTracker.Notifications.Dispatcher

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    # Subscribe to this user's notification topic when connected
    if connected?(socket) do
      Phoenix.PubSub.subscribe(FocusTracker.PubSub, Dispatcher.user_topic(user.id))
    end

    recent_notifications = Dispatcher.list_for_user(user.id, 5)

    {:ok,
     socket
     |> assign(:filters, %{})
     |> assign(:activities, Activities.list_activities(user.id))
     |> assign(:form, to_form(Activities.Activity.changeset(%Activities.Activity{}, %{})))
     |> assign(:editing, nil)
     |> assign(:notifications, recent_notifications)
     |> assign(:show_notifications, false)}
  end

  @impl true
  def handle_event("filter", %{"filters" => filters}, socket) do
    user = socket.assigns.current_user
    activities = Activities.list_activities(user.id, filters)
    {:noreply, assign(socket, activities: activities, filters: filters)}
  end

  def handle_event("create", %{"activity" => params}, socket) do
    user = socket.assigns.current_user

    case Activities.create_activity(user.id, params) do
      {:ok, _activity} ->
        activities = Activities.list_activities(user.id, socket.assigns.filters)

        {:noreply,
         socket
         |> put_flash(:info, "Activity created.")
         |> assign(:activities, activities)
         |> assign(:form, to_form(Activities.Activity.changeset(%Activities.Activity{}, %{})))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("complete", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    activity = Activities.get_activity!(user.id, id)
    {:ok, _} = Activities.complete_activity(activity)
    activities = Activities.list_activities(user.id, socket.assigns.filters)

    {:noreply,
     socket
     |> assign(:activities, activities)
     |> put_flash(:info, "Marked complete!")}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    activity = Activities.get_activity!(user.id, id)
    {:ok, _} = Activities.delete_activity(activity)
    activities = Activities.list_activities(user.id, socket.assigns.filters)

    {:noreply,
     socket
     |> assign(:activities, activities)
     |> put_flash(:info, "Activity deleted.")}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    activity = Activities.get_activity!(user.id, id)
    changeset = Activities.Activity.update_changeset(activity, %{})

    {:noreply, assign(socket, editing: activity, form: to_form(changeset))}
  end

  def handle_event("update", %{"activity" => params}, socket) do
    user = socket.assigns.current_user
    activity = socket.assigns.editing

    case Activities.update_activity(activity, params) do
      {:ok, _} ->
        activities = Activities.list_activities(user.id, socket.assigns.filters)

        {:noreply,
         socket
         |> put_flash(:info, "Activity updated.")
         |> assign(:activities, activities)
         |> assign(:editing, nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("cancel_edit", _, socket) do
    {:noreply,
     assign(socket,
       editing: nil,
       form: to_form(Activities.Activity.changeset(%Activities.Activity{}, %{}))
     )}
  end

  @impl true
  def handle_event("toggle_notifications", _, socket) do
    {:noreply, assign(socket, show_notifications: !socket.assigns.show_notifications)}
  end

  def handle_event("dismiss_notifications", _, socket) do
    {:noreply, assign(socket, show_notifications: false)}
  end

  # ── Handle incoming PubSub notification ──────────────────────────────

  @impl true
  def handle_info({:notification, notif}, socket) do
    updated = [notif | socket.assigns.notifications] |> Enum.take(5)
    {:noreply,
     socket
     |> assign(:notifications, updated)
     |> assign(:show_notifications, true)
     |> put_flash(:info, notif.message)}
  end

  defp deadline_class(activity) do
    now = DateTime.utc_now()

    cond do
      activity.status == "completed" ->
        "bg-gray-100 text-gray-400"

      DateTime.compare(activity.deadline, now) == :lt ->
        "bg-red-100 text-red-600"

      DateTime.diff(activity.deadline, now) < 86400 ->
        "bg-amber-100 text-amber-700"

      true ->
        "bg-blue-50 text-blue-600"
    end
  end

  defp format_deadline(deadline) do
    now = DateTime.utc_now()
    diff = DateTime.diff(deadline, now)

    cond do
      diff < 0 ->
        "Overdue by #{abs(div(diff, 3600))}h"

      diff < 3600 ->
        "Due in #{div(diff, 60)}m"

      diff < 86400 ->
        "Due in #{div(diff, 3600)}h"

      true ->
        deadline
        |> DateTime.to_date()
        |> Date.to_string()
        |> then(&"Due #{&1}")
    end
  end
end
