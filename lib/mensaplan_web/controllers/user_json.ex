defmodule MensaplanWeb.UserJSON do
  alias Mensaplan.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    for(user <- users, do: data(user))
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    data(user)
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      auth_id: user.auth_id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      inserted_at: user.inserted_at,
      default_public: user.default_public,
      updated_at: user.updated_at
    }
  end
end
