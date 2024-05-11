defmodule MensaplanWeb.PositionControllerTest do
  use MensaplanWeb.ConnCase

  import Mensaplan.PositionsFixtures

  alias Mensaplan.Positions.Position

  @create_attrs %{
    y: 120.5,
    x: 120.5
  }
  @update_attrs %{
    y: 456.7,
    x: 456.7
  }
  @invalid_attrs %{y: nil, x: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all positions", %{conn: conn} do
      conn = get(conn, ~p"/api/positions")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create position" do
    test "renders position when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/positions", position: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/positions/#{id}")

      assert %{
               "id" => ^id,
               "x" => 120.5,
               "y" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/positions", position: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update position" do
    setup [:create_position]

    test "renders position when data is valid", %{conn: conn, position: %Position{id: id} = position} do
      conn = put(conn, ~p"/api/positions/#{position}", position: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/positions/#{id}")

      assert %{
               "id" => ^id,
               "x" => 456.7,
               "y" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, position: position} do
      conn = put(conn, ~p"/api/positions/#{position}", position: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete position" do
    setup [:create_position]

    test "deletes chosen position", %{conn: conn, position: position} do
      conn = delete(conn, ~p"/api/positions/#{position}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/positions/#{position}")
      end
    end
  end

  defp create_position(_) do
    position = position_fixture()
    %{position: position}
  end
end
