defmodule FocusTracker.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id,          :binary_id, primary_key: true
      add :user_id,     references(:users, type: :binary_id, on_delete: :nothing), null: false
      add :activity_id, references(:activities, type: :binary_id, on_delete: :nothing), null: false
      add :type,        :string, null: false
      add :message,     :text, null: false
      add :sent_at,     :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:activity_id])
    create index(:notifications, [:sent_at])
  end
end
