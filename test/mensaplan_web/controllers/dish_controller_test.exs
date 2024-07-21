defmodule MensaplanWeb.DishControllerTest do
  use MensaplanWeb.ConnCase

  import Mensaplan.MensaFixtures

  alias Mensaplan.Mensa.Dish

  @create_attrs %{
    category: "some category",
    name: "some name",
    price: "some price"
  }
  @update_attrs %{
    category: "some updated category",
    name: "some updated name",
    price: "some updated price"
  }
  @invalid_attrs %{category: nil, name: nil, price: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all dishes", %{conn: conn} do
      conn = get(conn, ~p"/api/dishes")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create dish" do
    test "renders dish when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/dishes", dish: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/dishes/#{id}")

      assert %{
               "id" => ^id,
               "category" => "some category",
               "name" => "some name",
               "price" => "some price"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/dishes", dish: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update dish" do
    setup [:create_dish]

    test "renders dish when data is valid", %{conn: conn, dish: %Dish{id: id} = dish} do
      conn = put(conn, ~p"/api/dishes/#{dish}", dish: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/dishes/#{id}")

      assert %{
               "id" => ^id,
               "category" => "some updated category",
               "name" => "some updated name",
               "price" => "some updated price"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, dish: dish} do
      conn = put(conn, ~p"/api/dishes/#{dish}", dish: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete dish" do
    setup [:create_dish]

    test "deletes chosen dish", %{conn: conn, dish: dish} do
      conn = delete(conn, ~p"/api/dishes/#{dish}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/dishes/#{dish}")
      end
    end
  end

  defp create_dish(_) do
    dish = dish_fixture()
    %{dish: dish}
  end
end
