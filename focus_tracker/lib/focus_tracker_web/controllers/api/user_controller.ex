defmodule FocusTrackerWeb.Api.UserController do
  use FocusTrackerWeb, :controller

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    json(conn, %{
      id: user.id,
      email: user.email,
      name: user.name,
      avatar_url: user.avatar_url
    })
  end
end
