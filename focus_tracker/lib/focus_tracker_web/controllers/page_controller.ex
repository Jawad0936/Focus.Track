defmodule FocusTrackerWeb.PageController do
  use FocusTrackerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
