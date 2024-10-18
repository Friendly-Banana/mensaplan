defmodule MensaplanWeb.ProxyController do
  use MensaplanWeb, :controller

  def sign(url) do
    secret_key = Application.fetch_env!(:mensaplan, MensaplanWeb.ProxyController)[:secret_key]
    signature = :crypto.mac(:hmac, :sha256, secret_key, url) |> Base.encode32()
    ~p"/proxy/#{signature}/#{url}"
  end

  def proxy(conn, %{"url" => url, "signature" => signature}) do
    secret_key = Application.fetch_env!(:mensaplan, MensaplanWeb.ProxyController)[:secret_key]
    expected_signature = :crypto.mac(:hmac, :sha256, secret_key, url) |> Base.encode32()

    if signature != expected_signature do
      send_resp(conn, 401, "Unauthorized")
    else
      case Req.get(url, http_errors: :raise) do
        {:ok, %{body: body}} ->
          img = Image.thumbnail!(Image.from_binary!(body), 300)
          conn = put_resp_header(conn, "cache-control", "public, immutable, max-age=31536000")
          conn = send_chunked(conn, 200)

          img
          |> Image.stream!(suffix: ".png", buffer_size: 3 * 1024 * 1024, progressive: true)
          |> Enum.reduce_while(conn, fn chunk, conn ->
            case chunk(conn, chunk) do
              {:ok, conn} -> {:cont, conn}
              {:error, "closed"} -> {:halt, conn}
            end
          end)

        {:error, _} ->
          conn
          |> put_status(404)
          |> text("Image not found")
      end
    end
  end
end
