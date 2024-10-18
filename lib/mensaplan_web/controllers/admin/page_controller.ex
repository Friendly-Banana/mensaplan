defmodule MensaplanWeb.Admin.PageController do
  use MensaplanWeb, :controller

  def overview(conn, _params) do
    render(conn, :overview, page_title: "Admin Page")
  end
end
