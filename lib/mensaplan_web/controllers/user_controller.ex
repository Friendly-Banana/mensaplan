defmodule MensaplanWeb.UserController do
  use MensaplanWeb, :controller

  alias Mensaplan.Accounts
  alias Mensaplan.Accounts.User

  action_fallback MensaplanWeb.FallbackController

  def get_or_create(conn, %{"user" => user_params}) do
    user_params = Map.new(user_params, fn {k, v} -> {String.to_existing_atom(k), v} end)

    case Accounts.get_user_by_auth_id(user_params.auth_id) do
      nil ->
        case Accounts.create_user(user_params) do
          {:ok, %User{} = user} ->
            conn
            |> put_status(:created)
            |> render(:show, user: user)
        end

      user ->
        render(conn, :show, user: user)
    end
  end
end
