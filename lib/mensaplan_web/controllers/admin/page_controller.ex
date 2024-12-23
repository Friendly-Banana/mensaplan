defmodule MensaplanWeb.Admin.PageController do
  use MensaplanWeb, :controller

  @cat_images File.ls!("priv/static/images/cats")

  def overview(conn, _params) do
    random_image = Enum.random(@cat_images)
    render(conn, :overview, page_title: "Admin Page", random_image: "/images/cats/#{random_image}")
  end

  def fetch_dishes(conn, _params) do
    {state, msg} = GenServer.call(Mensaplan.Periodically, :fetch_dishes)

    conn
    |> put_flash(if(state == :ok, do: :info, else: :error), msg)
    |> redirect(to: ~p"/admin")
  end
end
