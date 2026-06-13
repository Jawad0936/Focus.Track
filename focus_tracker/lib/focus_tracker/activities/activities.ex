defmodule FocusTracker.Activities do
  import Ecto.Query, warn: false
  alias FocusTracker.Repo
  alias FocusTracker.Activities.Activity
  alias FocusTracker.Logs

  @doc "List all non-deleted activities for a user, with optional filters"
  def list_activities(user_id, filters \\ %{}) do
    Activity
    |> where([a], a.user_id == ^user_id and is_nil(a.deleted_at))
    |> apply_filters(filters)
    |> order_by([a], [asc_nulls_last: a.deadline, desc: a.inserted_at])
    |> Repo.all()
  end

  @doc "Get a single activity — only if it belongs to the user"
  def get_activity!(user_id, id) do
    Activity
    |> where([a], a.id == ^id and a.user_id == ^user_id and is_nil(a.deleted_at))
    |> Repo.one!()
  end

  @doc "List all pending activities that have deadlines (used by NotificationScheduler)"
  def list_pending_with_deadlines do
    Activity
    |> where([a], a.status == "pending" and not is_nil(a.deadline) and is_nil(a.deleted_at))
    |> preload(:user)
    |> Repo.all()
  end

  def create_activity(user_id, attrs) do
    %Activity{user_id: user_id}
    |> Activity.changeset(attrs)
    |> Repo.insert()
  end

  def update_activity(%Activity{} = activity, attrs) do
    activity
    |> Activity.update_changeset(attrs)
    |> Repo.update()
  end

  @doc "Soft-delete an activity and auto-create a system log in one transaction"
  def delete_activity(%Activity{} = activity) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:activity, Activity.delete_changeset(activity))
    |> Ecto.Multi.run(:system_log, fn _repo, _changes ->
      Logs.create_system_log(activity.id, "Activity deleted on #{now}")
    end)
    |> Repo.transaction()
  end

  def complete_activity(%Activity{} = activity) do
    activity
    |> Activity.complete_changeset()
    |> Repo.update()
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {"status", ""}, q -> q
      {"status", status}, q -> where(q, [a], a.status == ^status)

      {"category", ""}, q -> q
      {"category", cat}, q -> where(q, [a], a.category == ^cat)

      {"deadline", "today"}, q ->
        today = Date.utc_today()
        where(q, [a], fragment("DATE(?)", a.deadline) == ^today)

      {"deadline", "overdue"}, q ->
        now = DateTime.utc_now()
        where(q, [a], a.deadline < ^now and a.status == "pending")

      {"deadline", "week"}, q ->
        now = DateTime.utc_now()
        week_end = DateTime.add(now, 7 * 24 * 3600)
        where(q, [a], a.deadline >= ^now and a.deadline <= ^week_end)

      _, q -> q
    end)
  end
end
