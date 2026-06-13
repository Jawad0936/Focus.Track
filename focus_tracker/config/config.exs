# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :focus_tracker,
  ecto_repos: [FocusTracker.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :focus_tracker, FocusTrackerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: FocusTrackerWeb.ErrorHTML, json: FocusTrackerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: FocusTracker.PubSub,
  live_view: [signing_salt: "CrBY9Cns"]

  #configure database connection pool
  config :focus_tracker, FocusTracker.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "focus_tracker_dev",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :focus_tracker, FocusTracker.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  focus_tracker: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  focus_tracker: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Ueberauth — Google OAuth provider
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [
      default_scope: "email profile",
      prompt: "select_account"
    ]}
  ]

# Guardian — JWT config
config :focus_tracker, FocusTracker.Guardian,
  issuer: "focus_tracker",
  secret_key: System.get_env("GUARDIAN_SECRET") || "dev_secret_change_in_prod"


# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
