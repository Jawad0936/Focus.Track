defmodule FocusTracker.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notifications" do
    field :type, :string
    field :message, :string
    field :sent_at, :utc_datetime

    belongs_to :user, FocusTracker.Accounts.User
    belongs_to :activity, FocusTracker.Activities.Activity

    timestamps(type: :utc_datetime)
  end

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :activity_id, :type, :message, :sent_at])
    |> validate_required([:user_id, :activity_id, :type, :message, :sent_at])
    |> validate_inclusion(:type, ~w(upcoming overdue))
  end
end
