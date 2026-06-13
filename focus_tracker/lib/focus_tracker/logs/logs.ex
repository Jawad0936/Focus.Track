defmodule FocusTracker.Logs do
  import Ecto.Query, warn: false
  alias FocusTracker.Repo
  alias FocusTracker.Logs.Log
  alias FocusTracker.Activities.Activity

  def list_logs(activity_id) do
    Log
    |> where([l], l.activity_id == ^activity_id)
    |> order_by([l], desc: l.inserted_at)
    |> Repo.all()
  end

  def get_log!(id), do: Repo.get!(Log, id)

  def create_log(activity_id, attrs) do
    %Log{activity_id: activity_id}
    |> Log.changeset(attrs)
    |> Repo.insert()
  end

  def create_system_log(activity_id, message) do
    Log.system_changeset(activity_id, message)
    |> Repo.insert()
  end

  def update_log(%Log{} = log, attrs) do
    activity = Repo.get!(Activity, log.activity_id)

    cond do
      log.system -> {:error, :system_log}
      not is_nil(activity.deleted_at) -> {:error, :activity_deleted}
      true ->
        log
        |> Log.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete_log(%Log{} = log) do
    activity = Repo.get!(Activity, log.activity_id)

    cond do
      log.system -> {:error, :system_log}
      not is_nil(activity.deleted_at) -> {:error, :activity_deleted}
      true -> Repo.delete(log)
    end
  end
end
