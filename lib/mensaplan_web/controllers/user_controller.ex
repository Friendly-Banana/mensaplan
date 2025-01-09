defmodule MensaplanWeb.UserController do
  use MensaplanWeb, :controller

  alias Mensaplan.Accounts
  alias Mensaplan.Accounts.User

  action_fallback MensaplanWeb.FallbackController

  def get_or_create(conn, %{"auth_id" => auth_id, "user" => user_params}) do
    user_params = Map.new(user_params, fn {k, v} -> {String.to_existing_atom(k), v} end)
    user_params = Map.put(user_params, :auth_id, auth_id)

    case Accounts.create_or_update_user(user_params) do
      {:ok, %User{} = user} ->
        conn
        |> put_status(:ok)
        |> render(:show, user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(MensaplanWeb.ChangesetJSON.error(%{changeset: changeset}))
    end
  end
end
