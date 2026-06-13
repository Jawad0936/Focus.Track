alias FocusTracker.Repo
alias FocusTracker.Accounts.User
alias FocusTracker.Notifications.{Scheduler, Notification}
alias FocusTracker.Activities

# Ensure test user exists
user =
  case Repo.get_by(User, email: "test@example.com") do
    nil ->
      Repo.insert!(%User{email: "test@example.com", google_id: "test-notif-1", name: "Automated Test"})
    u ->
      u
  end

# Create an overdue activity (1 hour in the past)
{:ok, activity} =
  Activities.create_activity(user.id, %{
    description: "Overdue test activity",
    category: "work",
    deadline: DateTime.add(DateTime.utc_now(), -3600, :second)
  })

IO.inspect(activity, label: "Inserted activity")

# Trigger scheduler immediately
Scheduler.check_now()

# Brief sleep to let async work complete
:timer.sleep(500)

notifs = Repo.all(Notification)
IO.inspect(notifs, label: "Notifications in DB")
