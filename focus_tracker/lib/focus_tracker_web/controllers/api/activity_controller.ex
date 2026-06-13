defmodule FocusTrackerWeb.Api.ActivityController do
  use FocusTrackerWeb, :controller

  action_fallback FocusTrackerWeb.Api.FallbackController

  alias FocusTracker.Activities

  def index(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    filters = Map.take(params, ["status", "category", "deadline"])
    activities = Activities.list_activities(user.id, filters)

    json(conn, %{data: Enum.map(activities, &serialize_activity/1)})
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    try do
      activity = Activities.get_activity!(user.id, id)
      json(conn, %{data: serialize_activity(activity)})
    rescue
      Ecto.NoResultsError -> {:error, :not_found}
    end
  end

  def complete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    try do
      activity = Activities.get_activity!(user.id, id)

      case Activities.complete_activity(activity) do
        {:ok, updated} ->
          json(conn, %{data: serialize_activity(updated)})

        {:error, changeset} ->
          {:error, changeset}
      end
    rescue
      Ecto.NoResultsError -> {:error, :not_found}
    end
  end

  defp serialize_activity(a) do
    %{
      id: a.id,
      description: a.description,
      category: a.category,
      status: a.status,
      deadline: format_dt(a.deadline),
      completed_at: format_dt(a.completed_at),
      inserted_at: format_dt(a.inserted_at),
      updated_at: format_dt(a.updated_at)
    }
  end

  defp format_dt(nil), do: nil
  defp format_dt(dt), do: DateTime.to_iso8601(dt)
end
