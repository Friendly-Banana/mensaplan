defmodule Mensaplan.Helpers do
  def local_now do
    DateTime.now!("Europe/Berlin")
  end

  def change_locale(conn, old, new_locale) do
    current_path = Phoenix.Controller.current_path(conn)
    String.replace_prefix(current_path, "/#{old}", "/#{new_locale}")
  end

  def path_without_locale(conn) do
    String.replace_prefix(conn.request_path, "/" <> Gettext.get_locale(MensaplanWeb.Gettext), "/")
  end

  def locale_patch(url) do
    Phoenix.LiveView.JS.patch("/" <> Gettext.get_locale(MensaplanWeb.Gettext) <> url)
  end
end
