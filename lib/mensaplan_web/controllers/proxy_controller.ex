defmodule MensaplanWeb.ProxyController do
  use MensaplanWeb, :controller

  def sign(url) do
    "https://mensa.grabriel.co/cdn-cgi/image/format=auto,fit=scale-down,width=300/#{url}"
  end
end
