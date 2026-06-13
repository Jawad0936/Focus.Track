defmodule FocusTracker.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :activity_id, references(:activities, type: :binary_id, on_delete: :nothing), null: false
      add :description, :text, null: false
      add :system, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:logs, [:activity_id])
  end
end
