defmodule MensaplanWeb.PageController do
  use MensaplanWeb, :controller

  def home(conn, _params) do
    conn = assign(conn, :user, get_session(conn, :current_user))
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
