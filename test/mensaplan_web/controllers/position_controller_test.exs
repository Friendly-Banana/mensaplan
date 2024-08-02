defmodule MensaplanWeb.PositionControllerTest do
  use MensaplanWeb.ConnCase

  import Mensaplan.PositionsFixtures

  alias Mensaplan.Positions
  alias Mensaplan.Accounts
  alias Mensaplan.AccountsFixtures

  @create_attrs %{
    y: 20.5,
    x: 20.5
  }
  @invalid_attrs %{y: nil, x: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json") |> authorize()}
  end

  test "create a position", %{conn: conn} do
    user = AccountsFixtures.user_fixture()
    position = position_fixture(%{owner_id: user.id})

    conn = post(conn, ~p"/api/positions/", position: Map.put(@create_attrs, "owner_id", user.id))

    resp = json_response(conn, 201)

    assert user.id == resp["owner"]
    assert Positions.get_position!(position.id).expired
  end

  test "renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, ~p"/api/positions/", position: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "expire all positions for a user", %{conn: conn} do
    user = AccountsFixtures.user_fixture()
    position = position_fixture(%{owner_id: user.id})

    conn = delete(conn, ~p"/api/positions/user/#{user.auth_id}")
    assert response(conn, 204)
    assert Positions.get_position!(position.id).expired
  end

  test "list all positions for a server", %{conn: conn} do
    server = "123"
    group = AccountsFixtures.group_fixture(%{server_id: server})
    user = AccountsFixtures.user_fixture()
    Accounts.add_user_to_group(user, group)
    position = position_fixture(%{owner_id: user.id})

    conn = get(conn, ~p"/api/positions/server/#{server}")

    assert json_response(conn, 200) == [
             %{
               "id" => position.id,
               "name" => user.name,
               "avatar" => user.avatar,
               "x" => position.x,
               "y" => position.y
             }
           ]
  end
end
