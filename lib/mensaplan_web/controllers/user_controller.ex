defmodule MensaplanWeb.UserController do
  use MensaplanWeb, :controller

  alias Mensaplan.Accounts
  alias Mensaplan.Accounts.User

  action_fallback MensaplanWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    if user = Accounts.get_user_by_auth_id(id) do
      render(conn, :show, user: user)
    else
      {:error, :not_found}
    end
  end
end
