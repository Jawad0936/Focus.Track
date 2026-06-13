defmodule FocusTracker.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :nothing), null: false
      add :description, :text, null: false
      add :category, :string, null: false
      add :status, :string, default: "pending", null: false
      add :deadline, :utc_datetime
      add :completed_at, :utc_datetime
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:activities, [:user_id])
    create index(:activities, [:status])
    create index(:activities, [:deadline])
  end
end
