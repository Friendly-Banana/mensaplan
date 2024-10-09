defmodule MensaplanWeb.DishControllerTest do
  use MensaplanWeb.ConnCase

  import Mensaplan.MensaFixtures

  describe "show dish" do
    test "renders form for editing chosen dish", %{conn: conn} do
      dish = dish_fixture()
      conn = get(conn, ~p"/en/dishes/#{dish}")
      assert html_response(conn, 200) =~ dish.name_en
    end
  end
end
