defmodule FocusTrackerWeb.Api.FallbackController do
  use Phoenix.Controller, formats: [:json]

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Not found"})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Forbidden"})
  end

  def call(conn, {:error, :system_log}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "System logs cannot be modified"})
  end

  def call(conn, {:error, :activity_deleted}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Logs for deleted activities are read-only"})
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, val}, acc ->
          String.replace(acc, "%{#{key}}", to_string(val))
        end)
      end)

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Validation failed", details: errors})
  end
end
