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
    |> put_flash(:info, dgettext("messages", "You have been logged out!"))
    |> delete_resp_cookie(@remember_me_cookie)
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{} = fail}} = conn, _params) do
    Logger.warning("Failed to authenticate: #{inspect(fail)}")

    conn
    |> put_flash(:error, "Failed to authenticate")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    case Accounts.create_or_update_user(basic_info(auth)) do
      {:ok, user} ->
        conn
        |> put_flash(:info, dgettext("messages", "Successfully authenticated."))
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
  end

  def basic_info(auth) do
    %{
      auth_id: "oauth2|#{auth.provider}|#{auth.uid}",
      name: name_from_auth(auth),
      email: auth.info.email,
      avatar: auth.info.image
    }
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name =
        [auth.info.first_name, auth.info.last_name]
        |> Enum.filter(&(&1 != nil and &1 != ""))

      if Enum.empty?(name) do
        auth.info.nickname
      else
        Enum.join(name, " ")
      end
    end
  end
end
