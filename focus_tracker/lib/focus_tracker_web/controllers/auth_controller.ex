defmodule FocusTrackerWeb.AuthController do
  use FocusTrackerWeb, :controller
  plug Ueberauth

  alias FocusTracker.Accounts
  alias FocusTracker.Guardian

  def login(conn, _params) do
    render(conn, "login.html")
  end

  # GET /auth/:provider
  def request(conn, _params), do: conn

  # Callback after Google authentication
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.find_or_create_from_google(auth) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Welcome, #{user.name || user.email}!")
        |> redirect(to: "/activities")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Authentication failed. Please try again.")
        |> redirect(to: "/auth/google")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    reason = Enum.map(failure.errors, & &1.message) |> Enum.join(", ")

    conn
    |> put_flash(:error, "Failed to authenticate: #{reason}")
    |> redirect(to: "/auth/google")
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "Logged out.")
    |> redirect(to: "/auth/google")
  end

  @doc """
  POST /api/v1/auth/google
  Mobile sends: %{"google_token" => "..."}
  We verify with Google, find/create user, return JWT.
  """
  def mobile_login(conn, %{"google_token" => google_token}) do
    with {:ok, google_user} <- verify_google_token(google_token),
         {:ok, user} <- Accounts.find_or_create_from_google_data(google_user),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      json(conn, %{token: token})
    else
      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication failed", reason: to_string(reason)})
    end
  end

  defp verify_google_token(token) do
    :inets.start()
    :ssl.start()

    url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{token}"

    case :httpc.request(:get, {String.to_charlist(url), []}, [], []) do
      {:ok, {{_, 200, _}, _, body}} ->
        data = body |> List.to_string() |> Jason.decode!()

        {:ok,
         %{
           uid: data["sub"],
           email: data["email"],
           name: data["name"],
           image: data["picture"]
         }}

      _ ->
        {:error, :invalid_token}
    end
  end
end
