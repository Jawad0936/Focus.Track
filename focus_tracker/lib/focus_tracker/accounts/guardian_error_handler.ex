defmodule FocusTracker.Guardian.ErrorHandler do
  import Plug.Conn
  use FocusTrackerWeb, :controller

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_flash(:error, "You must be logged in. (#{type})")
    |> redirect(to: "/auth/google")
  end
end
