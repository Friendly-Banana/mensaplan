defmodule MensaplanWeb.PageController do
  use MensaplanWeb, :controller

  alias Mensaplan.Repo
  alias Mensaplan.UserData.Position

  def home(conn, _params) do
    conn = assign(conn, :positions, Repo.all(Position))
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def about(conn, _params) do
    render(conn, :about)
  end
end
