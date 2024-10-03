defmodule MensaplanWeb.AccessControl do
  use MensaplanWeb, :controller

  import Plug.Conn
  alias Mensaplan.Accounts

  def require_login(conn, _opts) do
    if user = get_session(conn, :user) do
      assign(conn, :user, user)
    else
      conn
      |> put_flash(:error, dgettext("errors", "Please login to access this page."))
      |> redirect(to: "/")
      |> halt()
    end
  end

  def admin_only(conn, _opts) do
    if conn.assigns[:user].id == 1 do
      conn
    else
      conn
      |> put_flash(:error, dgettext("errors", "Please login to access this page."))
      |> redirect(to: "/")
      |> halt()
    end
  end

  def require_api_token(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         secret <- System.get_env("API_TOKEN"),
         true <- byte_size(token) == byte_size(secret) && :crypto.hash_equals(token, secret) do
      conn
      |> assign(:user, Accounts.get_user!(2))
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "Unauthorized")
        |> halt()
    end
  end
end
