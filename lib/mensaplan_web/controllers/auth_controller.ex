defmodule MensaplanWeb.AuthController do
  use MensaplanWeb, :controller

  plug Ueberauth

  require Logger
  alias Mensaplan.Accounts
  alias Mensaplan.Accounts.UserToken

  # Remember to set the same value in the UserToken module
  @max_age 365 * 60 * 24 * 60
  @remember_me_cookie "_mensaplan_web_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax", secure: true]

  def fetch_user_from_cookie(conn, _opts) do
    if get_session(conn, :user) do
      conn
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        if user = UserToken.get_user_by_token(token) do
          conn
          |> put_session(:user, user)
          |> configure_session(renew: true)
        else
          conn
        end
      else
        conn
      end
    end
  end

  def delete(conn, _params) do
    if token = fetch_cookies(conn, signed: [@remember_me_cookie]).cookies[@remember_me_cookie] do
      UserToken.delete_user_token(token)
    end

    conn
    |> put_flash(:info, "You have been logged out!")
    |> delete_resp_cookie(@remember_me_cookie)
    |> clear_session()
    |> redirect(to: "/")
  end

  defp get_or_create_user(oauth_user) do
    if user = Accounts.get_user_by_auth_id(oauth_user.id) do
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
            |> put_resp_cookie(
              @remember_me_cookie,
              UserToken.generate_user_token(user),
              @remember_me_options
            )
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
