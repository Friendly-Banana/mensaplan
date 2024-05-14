defmodule MensaplanWeb.PageController do
  use MensaplanWeb, :controller

  alias Mensaplan.Accounts

  def about(conn, _params) do
    render(conn, :about)
  end

  def update_user_in_session(conn, _params) do
    user = get_session(conn, :user)

    if user do
      put_session(conn, :user, Accounts.get_user!(user.id))
      |> redirect(to: "/settings")
    else
      redirect(conn, to: "/")
    end
  end
end
