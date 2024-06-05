defmodule MensaplanWeb.AccessControl do
  use MensaplanWeb, :controller

  import Plug.Conn

  def require_login(conn, _opts) do
    if user = get_session(conn, :user) do
      assign(conn, :user, user)
    else
      conn
      |> put_flash(:error, "Please login to access this page.")
      |> redirect(to: "/")
      |> halt()
    end
  end

  def admin_only(conn, _opts) do
    if conn.assigns[:user].id == 1 do
      conn
    else
      conn
      |> put_flash(:error, "Please login to access this page.")
      |> redirect(to: "/")
      |> halt()
    end
  end

  def require_api_token(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         true <- token == Application.get_env(:mensaplan, :api_token) do
      conn
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "Unauthorized")
        |> halt()
    end
  end
end
