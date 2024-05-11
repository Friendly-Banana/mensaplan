defmodule MensaplanWeb.PageController do
  use MensaplanWeb, :controller

  def about(conn, _params) do
    render(conn, :about)
  end

  def settings(conn, _params) do
    if user = get_session(conn, :user) do
      render(conn, :settings, user: user)
    else
      conn
      |> put_flash(:error, "You need to be logged in to access this page.")
      |> redirect(to: "/")
    end
  end
end
