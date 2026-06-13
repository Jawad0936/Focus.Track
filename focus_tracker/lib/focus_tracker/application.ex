defmodule FocusTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FocusTrackerWeb.Telemetry,
      FocusTracker.Repo,
      {DNSCluster, query: Application.get_env(:focus_tracker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FocusTracker.PubSub},
      # Start a worker by calling: FocusTracker.Worker.start_link(arg)
      # {FocusTracker.Worker, arg},
      # Start to serve requests, typically the last entry
      FocusTrackerWeb.Endpoint,

      # Notifications scheduler
      FocusTracker.Notifications.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FocusTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FocusTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
