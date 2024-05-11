defmodule MensaplanWeb.AuthController do
  use MensaplanWeb, :controller

  plug Ueberauth

  require Logger
  alias Mensaplan.Accounts

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end

  defp get_or_create_user(oauth_user) do
    if user = Accounts.get_user(oauth_user.id) do
      {:ok, user}
    else
      Accounts.create_user(Map.put(oauth_user, :auth_id, oauth_user[:id]))
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.extract_info(auth) do
      {:ok, oauth_user} ->
        case get_or_create_user(oauth_user) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "Successfully authenticated.")
            |> put_session(:user, user)
            |> configure_session(renew: true)
            |> redirect(to: "/")

          {:error, reason} ->
            conn
            |> put_flash(:error, reason)
            |> redirect(to: "/")
        end

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
