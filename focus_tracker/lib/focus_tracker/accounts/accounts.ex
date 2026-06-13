defmodule FocusTracker.Accounts do
  import Ecto.Query, warn: false
  alias FocusTracker.Repo
  alias FocusTracker.Accounts.User

  @doc "Find a user by ID"
  def get_user(id), do: Repo.get(User, id)

  @doc "Find a user by email"
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Find or create a user from Google OAuth data.
  Called after successful Google login.
  """
  def find_or_create_from_google(%Ueberauth.Auth{} = auth) do
    google_id = to_string(auth.uid)
    email = auth.info.email
    name = auth.info.name
    avatar = auth.info.image

    case Repo.get_by(User, google_id: google_id) do
      nil ->
        %User{}
        |> User.changeset(%{
          google_id: google_id,
          email: email,
          name: name,
          avatar_url: avatar
        })
        |> Repo.insert()

      user ->
        user
        |> User.changeset(%{name: name, avatar_url: avatar})
        |> Repo.update()
    end
  end

  @doc "Same as find_or_create_from_google but accepts a plain map (for mobile token flow)"
  def find_or_create_from_google_data(%{uid: uid, email: email, name: name, image: image}) do
    case Repo.get_by(User, google_id: to_string(uid)) do
      nil ->
        %User{}
        |> User.changeset(%{
          google_id: to_string(uid),
          email: email,
          name: name,
          avatar_url: image
        })
        |> Repo.insert()

      user ->
        user
        |> User.changeset(%{name: name, avatar_url: image})
        |> Repo.update()
    end
  end
end
