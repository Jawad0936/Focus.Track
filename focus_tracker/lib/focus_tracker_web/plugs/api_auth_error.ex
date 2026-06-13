defmodule FocusTrackerWeb.Plugs.ApiAuthError do
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Jason.encode!(%{error: "Unauthorized", reason: to_string(type)}))
    |> halt()
  end
end
