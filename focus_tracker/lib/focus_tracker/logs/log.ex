defmodule FocusTracker.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "logs" do
    field :description, :string
    field :system, :boolean, default: false

    belongs_to :activity, FocusTracker.Activities.Activity

    timestamps(type: :utc_datetime)
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:description, :activity_id])
    |> validate_required([:description, :activity_id])
    |> validate_length(:description, min: 1, max: 1000)
  end

  def system_changeset(activity_id, message) do
    %__MODULE__{}
    |> cast(%{description: message, activity_id: activity_id, system: true}, [:description, :activity_id, :system])
    |> validate_required([:description, :activity_id])
  end
end
