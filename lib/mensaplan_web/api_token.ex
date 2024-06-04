defmodule MensaplanWeb.ApiToken do
  import Plug.Conn

  def require_api_token(conn, _opts) do
    auth = get_req_header(conn, "authorization")

    if Enum.empty?(auth) || List.first(auth) != System.get_env("API_TOKEN") do
      conn
      |> put_status(:unauthorized)
      |> halt()
    else
      conn
    end
  end
end
