defmodule FocusTrackerWeb.ActivityLive.Show do
  use FocusTrackerWeb, :live_view

  on_mount {FocusTrackerWeb.LiveAuth, :require_authenticated}

  alias FocusTracker.Activities
  alias FocusTracker.Logs
  alias FocusTracker.Logs.Log

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_user
    activity = Activities.get_activity!(user.id, id)
    logs = Logs.list_logs(activity.id)

    {:ok,
     socket
     |> assign(:activity, activity)
     |> assign(:logs, logs)
     |> assign(:create_form, to_form(Log.changeset(%Log{}, %{})))
     |> assign(:editing_log, nil)
     |> assign(:edit_form, nil)}
  end

  @impl true
  def handle_event("create_log", %{"log" => params}, socket) do
    activity = socket.assigns.activity

    case Logs.create_log(activity.id, params) do
      {:ok, _log} ->
        {:noreply,
         socket
         |> assign(:logs, Logs.list_logs(activity.id))
         |> assign(:create_form, to_form(Log.changeset(%Log{}, %{})))
         |> put_flash(:info, "Log added.")}

      {:error, changeset} ->
        {:noreply, assign(socket, create_form: to_form(changeset))}
    end
  end

  def handle_event("edit_log", %{"id" => id}, socket) do
    log = Logs.get_log!(id)
    changeset = Log.changeset(log, %{})

    {:noreply,
     socket
     |> assign(:editing_log, log)
     |> assign(:edit_form, to_form(changeset))}
  end

  def handle_event("update_log", %{"log" => params}, socket) do
    log = socket.assigns.editing_log

    case Logs.update_log(log, params) do
      {:ok, _log} ->
        {:noreply,
         socket
         |> assign(:logs, Logs.list_logs(socket.assigns.activity.id))
         |> assign(:editing_log, nil)
         |> assign(:edit_form, nil)
         |> put_flash(:info, "Log updated.")}

      {:error, :system_log} ->
        {:noreply, put_flash(socket, :error, "System logs cannot be edited.")}

      {:error, :activity_deleted} ->
        {:noreply, put_flash(socket, :error, "Logs for deleted activities are read-only.")}

      {:error, changeset} ->
        {:noreply, assign(socket, edit_form: to_form(changeset))}
    end
  end

  def handle_event("cancel_edit_log", _, socket) do
    {:noreply,
     socket
     |> assign(:editing_log, nil)
     |> assign(:edit_form, nil)}
  end

  def handle_event("delete_log", %{"id" => id}, socket) do
    log = Logs.get_log!(id)

    case Logs.delete_log(log) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:logs, Logs.list_logs(socket.assigns.activity.id))
         |> put_flash(:info, "Log deleted.")}

      {:error, :system_log} ->
        {:noreply, put_flash(socket, :error, "System logs cannot be deleted.")}

      {:error, :activity_deleted} ->
        {:noreply, put_flash(socket, :error, "Logs for deleted activities are read-only.")}
    end
  end

  def handle_event("complete_activity", _, socket) do
    activity = socket.assigns.activity

    case Activities.complete_activity(activity) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(:activity, updated)
         |> put_flash(:info, "Activity marked as complete!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not complete activity.")}
    end
  end

  # ── Helpers ───────────────────────────────────────────────────────────

  defp editable_log?(log, activity) do
    not log.system and is_nil(activity.deleted_at)
  end

  defp format_dt(nil), do: "—"

  defp format_dt(%DateTime{} = dt) do
    Calendar.strftime(dt, "%b %d, %Y at %H:%M")
  end

  defp deadline_status(deadline) do
    now = DateTime.utc_now()
    diff = DateTime.diff(deadline, now)

    cond do
      diff < 0 -> {:overdue, "Overdue by #{abs(div(diff, 3600))}h"}
      diff < 3600 -> {:soon, "Due in #{div(diff, 60)}m"}
      diff < 86_400 -> {:soon, "Due in #{div(diff, 3600)}h"}
      true -> {:ok, "Due #{Calendar.strftime(deadline, "%b %d")}"}
    end
  end
end
