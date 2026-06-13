alias FocusTracker.Repo
alias FocusTracker.Notifications.Dispatcher

activity = Repo.get_by(FocusTracker.Activities.Activity, description: "Overdue test activity")
IO.inspect(activity, label: "Found activity")

case Dispatcher.send(activity, :overdue, "Manual overdue notification for testing") do
  {:ok, notif} -> IO.inspect(notif, label: "Created notification")
  {:error, reason} -> IO.inspect(reason, label: "Dispatcher error")
end
