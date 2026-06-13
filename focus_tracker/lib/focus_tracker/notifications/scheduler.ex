defmodule FocusTracker.Notifications.Scheduler do
  @moduledoc """
  GenServer that periodically checks all pending activities
  and dispatches notifications based on deadline status.

  Tick interval: every 30 minutes
  Upcoming deadline:  notify every 8 hours
  Overdue:            notify every 4 hours
  """

  use GenServer
  require Logger

  alias FocusTracker.Activities
  alias FocusTracker.Notifications.Dispatcher

  # How often the GenServer wakes up to check
  @tick_ms 30 * 60 * 1000

  # How often to re-notify (in seconds)
  @upcoming_interval_s 8 * 60 * 60
  @overdue_interval_s  4 * 60 * 60

  # ── Public API ────────────────────────────────────────────────────────

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: Keyword.get(opts, :name, __MODULE__))
  end

  @doc "Manually trigger a check — useful for testing"
  def check_now do
    GenServer.cast(__MODULE__, :check)
  end

  # ── GenServer callbacks ───────────────────────────────────────────────

  @impl true
  def init(state) do
    Logger.info("[Scheduler] NotificationScheduler started.")
    schedule_tick()
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    Logger.info("[Scheduler] Tick — checking activities...")
    do_check()
    schedule_tick()
    {:noreply, state}
  end

  @impl true
  def handle_cast(:check, state) do
    do_check()
    {:noreply, state}
  end

  # ── Private ───────────────────────────────────────────────────────────

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_ms)
  end

  defp do_check do
    now = DateTime.utc_now()

    activities = Activities.list_pending_with_deadlines()
    Logger.info("[Scheduler] Found #{length(activities)} pending activities with deadlines.")

    Enum.each(activities, fn activity ->
      process_activity(activity, now)
    end)
  end

  defp process_activity(activity, now) do
    last_sent  = Dispatcher.last_sent_at(activity.id)
    secs_since = seconds_since(last_sent, activity.inserted_at, now)

    cond do
      overdue?(activity, now) and secs_since >= @overdue_interval_s ->
        hours = DateTime.diff(now, activity.deadline) |> div(3600)
        msg = "Activity '#{activity.description}' is overdue by #{hours} hour#{if hours == 1, do: "", else: "s"}."
        Dispatcher.send(activity, :overdue, msg)

      upcoming?(activity, now) and secs_since >= @upcoming_interval_s ->
        hours = DateTime.diff(activity.deadline, now) |> div(3600)
        msg = "Activity '#{activity.description}' is due in #{hours} hour#{if hours == 1, do: "", else: "s"}."
        Dispatcher.send(activity, :upcoming, msg)

      true ->
        :skip
    end
  end

  defp overdue?(activity, now) do
    DateTime.compare(activity.deadline, now) == :lt
  end

  defp upcoming?(activity, now) do
    DateTime.compare(activity.deadline, now) == :gt
  end

  defp seconds_since(nil, fallback, now) do
    # Never notified — use activity creation time as baseline
    DateTime.diff(now, fallback)
  end
  defp seconds_since(last_sent, _fallback, now) do
    DateTime.diff(now, last_sent)
  end
end
