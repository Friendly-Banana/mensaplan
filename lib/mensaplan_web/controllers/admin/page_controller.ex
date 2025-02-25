defmodule MensaplanWeb.Admin.PageController do
  use MensaplanWeb, :controller
  import Mensaplan.Helpers

  @cat_images File.ls!("priv/static/images/cats")

  def overview(conn, _params) do
    random_image = Enum.random(@cat_images)

    render(conn, :overview, page_title: "Admin Page", random_image: "/images/cats/#{random_image}")
  end

  def fetch_dishes(conn, %{"date" => date}) do
    parsed_date =
      case date do
        nil -> {:ok, local_now()}
        "" -> {:ok, local_now()}
        _ -> Date.from_iso8601(date)
      end

    case parsed_date do
      {:ok, valid_date} ->
        {state, msg} = GenServer.call(Mensaplan.Periodically, {:fetch_dishes, valid_date})

        conn
        |> put_flash(if(state == :ok, do: :info, else: :error), msg)
        |> redirect(to: ~p"/admin")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Invalid date format: #{reason}")
        |> redirect(to: ~p"/admin")
    end
  end
end
