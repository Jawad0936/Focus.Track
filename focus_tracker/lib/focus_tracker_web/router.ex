defmodule FocusTrackerWeb.Router do
  use FocusTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FocusTrackerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug FocusTracker.Guardian.AuthPipeline
  end

  pipeline :require_auth do
    plug FocusTracker.Guardian.AuthPipeline
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug FocusTrackerWeb.Plugs.ApiAuth
  end

  scope "/auth", FocusTrackerWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/api/v1", FocusTrackerWeb do
    pipe_through :api

    post "/auth/google", AuthController, :mobile_login
  end

  scope "/api/v1", FocusTrackerWeb.Api do
    pipe_through [:api, :api_auth]

    get "/me", UserController, :me
    get "/activities", ActivityController, :index
    get "/activities/:id", ActivityController, :show
    put "/activities/:id/complete", ActivityController, :complete
    get "/activities/:activity_id/logs", LogController, :index
  end

  scope "/", FocusTrackerWeb do
    pipe_through [:browser, :auth]

    get "/", AuthController, :login
  end

  scope "/", FocusTrackerWeb do
    pipe_through [:browser, :require_auth]

    live "/activities", ActivityLive.Index, :index
    live "/activities/:id", ActivityLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", FocusTrackerWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:focus_tracker, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
