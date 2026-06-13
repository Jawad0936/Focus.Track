defmodule FocusTrackerWeb.Api.LogController do
  use FocusTrackerWeb, :controller

  action_fallback FocusTrackerWeb.Api.FallbackController

  alias FocusTracker.{Activities, Logs}

  def index(conn, %{"activity_id" => activity_id}) do
    user = Guardian.Plug.current_resource(conn)

    try do
      _activity = Activities.get_activity!(user.id, activity_id)
      logs = Logs.list_logs(activity_id)
      json(conn, %{data: Enum.map(logs, &serialize_log/1)})
    rescue
      Ecto.NoResultsError -> {:error, :not_found}
    end
  end

  defp serialize_log(log) do
    %{
      id: log.id,
      description: log.description,
      system: log.system,
      inserted_at: DateTime.to_iso8601(log.inserted_at),
      updated_at: DateTime.to_iso8601(log.updated_at)
    }
  end
end
