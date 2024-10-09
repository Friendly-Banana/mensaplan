defmodule MensaplanWeb.DishControllerTest do
  use MensaplanWeb.ConnCase

  import Mensaplan.MensaFixtures

  @create_attrs %{category: "some category", name_de: "some name_de", name_en: "some name_en", price: "some price"}
  @update_attrs %{category: "some updated category", name_de: "some updated name_de", name_en: "some updated name_en", price: "some updated price"}
  @invalid_attrs %{category: nil, name_de: nil, name_en: nil, price: nil}

  describe "new dish" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/dishes/new")
      assert html_response(conn, 200) =~ "New Dish"
    end
  end

  describe "create dish" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/dishes", dish: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/dishes/#{id}"

      conn = get(conn, ~p"/dishes/#{id}")
      assert html_response(conn, 200) =~ "Dish #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/dishes", dish: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Dish"
    end
  end

  describe "edit dish" do
    setup [:create_dish]

    test "renders form for editing chosen dish", %{conn: conn, dish: dish} do
      conn = get(conn, ~p"/dishes/#{dish}/edit")
      assert html_response(conn, 200) =~ "Edit Dish"
    end
  end

  describe "update dish" do
    setup [:create_dish]

    test "redirects when data is valid", %{conn: conn, dish: dish} do
      conn = put(conn, ~p"/dishes/#{dish}", dish: @update_attrs)
      assert redirected_to(conn) == ~p"/dishes/#{dish}"

      conn = get(conn, ~p"/dishes/#{dish}")
      assert html_response(conn, 200) =~ "some updated category"
    end

    test "renders errors when data is invalid", %{conn: conn, dish: dish} do
      conn = put(conn, ~p"/dishes/#{dish}", dish: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Dish"
    end
  end

  describe "delete dish" do
    setup [:create_dish]

    test "deletes chosen dish", %{conn: conn, dish: dish} do
      conn = delete(conn, ~p"/dishes/#{dish}")
      assert redirected_to(conn) == ~p"/dishes"

      assert_error_sent 404, fn ->
        get(conn, ~p"/dishes/#{dish}")
      end
    end
  end

  defp create_dish(_) do
    dish = dish_fixture()
    %{dish: dish}
  end
end
