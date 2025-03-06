defmodule Mensaplan.Helpers do
  def local_now do
    DateTime.now!("Europe/Berlin")
  end

  def change_locale(conn, old, new_locale) do
    current_path = Phoenix.Controller.current_path(conn)
    String.replace_prefix(current_path, "/#{old}", "/#{new_locale}")
  end

  def locale_patch(url) do
    Phoenix.LiveView.JS.patch("/" <> Gettext.get_locale(MensaplanWeb.Gettext) <> url)
  end

  def proxy_image(url, options \\ "format=auto,fit=scale-down,width=300") do
    if Application.get_env(:mensaplan, :environment, :dev) == :prod do
      MensaplanWeb.Endpoint.url() <> "/cdn-cgi/image/#{options}/#{url}"
    else
      url
    end
  end

  def price(dish) do
    fixed = :erlang.float_to_binary(dish.fixed_price / 100, decimals: 2)
    unit = :erlang.float_to_binary(dish.price_per_unit / 100, decimals: 2)

    if dish.fixed_price == 0,
      do: "#{unit}€/100g",
      else: if(dish.price_per_unit == 0, do: "#{fixed}€", else: "#{fixed}€ + #{unit}€/100g")
  end
end
