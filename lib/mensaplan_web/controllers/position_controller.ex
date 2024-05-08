defmodule MensaplanWeb.PositionController do
  use MensaplanWeb, :controller

  alias Mensaplan.UserData
  alias Mensaplan.UserData.Position

  action_fallback MensaplanWeb.FallbackController

  def index(conn, _params) do
    positions = UserData.list_positions()
    render(conn, :index, positions: positions)
  end

  def create(conn, %{"position" => position_params}) do
    with {:ok, %Position{} = position} <- UserData.create_position(position_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/positions/#{position}")
      |> render(:show, position: position)
    end
  end

  def show(conn, %{"id" => id}) do
    position = UserData.get_position!(id)
    render(conn, :show, position: position)
  end

  def delete(conn, %{"id" => id}) do
    position = UserData.get_position!(id)

    with {:ok, %Position{}} <- UserData.delete_position(position) do
      send_resp(conn, :no_content, "")
    end
  end
end
