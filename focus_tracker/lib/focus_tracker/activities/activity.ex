defmodule FocusTracker.Activities.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_categories ~w(work learning health personal other)
  @valid_statuses ~w(pending completed)

  schema "activities" do
    field :description, :string
    field :category, :string
    field :status, :string, default: "pending"
    field :deadline, :utc_datetime
    field :completed_at, :utc_datetime
    field :deleted_at, :utc_datetime

    belongs_to :user, FocusTracker.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:description, :category, :deadline, :user_id])
    |> validate_required([:description, :category, :user_id])
    |> validate_inclusion(:category, @valid_categories)
    |> validate_length(:description, min: 3, max: 500)
  end

  def update_changeset(activity, attrs) do
    activity
    |> cast(attrs, [:description, :category, :deadline])
    |> validate_required([:description, :category])
    |> validate_inclusion(:category, @valid_categories)
    |> validate_length(:description, min: 3, max: 500)
  end

  def complete_changeset(activity) do
    activity
    |> change(status: "completed", completed_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> validate_inclusion(:status, @valid_statuses)
  end

  def delete_changeset(activity) do
    activity
    |> change(deleted_at: DateTime.utc_now() |> DateTime.truncate(:second))
  end
end
