defmodule MensaplanWeb.PositionController do
  use MensaplanWeb, :controller

  alias Mensaplan.Accounts
  alias Mensaplan.Positions
  alias Mensaplan.Positions.Position

  action_fallback MensaplanWeb.FallbackController

  def create_for_user(conn, %{"position" => position_params}) do
    Positions.expire_all_positions(position_params["owner_id"])

    with {:ok, %Position{} = position} <- Positions.create_position(position_params) do
      Phoenix.PubSub.broadcast(Mensaplan.PubSub, "positions", {:position_saved, position})

      conn
      |> put_status(:created)
      |> render(:show, position: position)
    end
  end

  def expire_for_user(conn, %{"auth_id" => auth_id}) do
    with user <- Accounts.get_user_by_auth_id(auth_id) do
      Positions.expire_all_positions(user.id)

      send_resp(conn, :no_content, "")
    end
  end

  def positions_for_server(conn, %{"server_id" => id}) do
    render(conn, :index, positions: Positions.list_positions_for_server(id))
  end
end
