import Ecto.Query, only: [from: 2]
alias FocusTracker.Repo
alias FocusTracker.Accounts.User
alias FocusTracker.Activities.Activity
alias FocusTracker.Notifications.Notification

user = Repo.get_by(User, email: "test@example.com")

if user do
  IO.puts("Found test user: #{user.id}, deleting related notifications and activities...")
  {n_deleted, _} = Repo.delete_all(from(n in Notification, where: n.user_id == ^user.id))
  {a_deleted, _} = Repo.delete_all(from(a in Activity, where: a.user_id == ^user.id))
  Repo.delete(user)
  IO.puts("Deleted #{n_deleted} notifications and #{a_deleted} activities for test user; user removed.")
else
  IO.puts("No test user found; nothing to delete.")
end

# Also remove any stray notifications with the manual test message
{m_deleted, _} = Repo.delete_all(from(n in Notification, where: n.message == "Manual overdue notification for testing"))
if m_deleted > 0, do: IO.puts("Also removed #{m_deleted} stray manual notification(s).")
