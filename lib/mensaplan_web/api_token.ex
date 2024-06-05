defmodule MensaplanWeb.ApiToken do
  import Plug.Conn

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
