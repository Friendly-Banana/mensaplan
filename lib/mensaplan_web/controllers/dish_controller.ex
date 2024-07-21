defmodule MensaplanWeb.DishController do
  use MensaplanWeb, :controller

  alias Mensaplan.Mensa
  alias Mensaplan.Mensa.Dish

  action_fallback MensaplanWeb.FallbackController

  def index(conn, _params) do
    dishes = Mensa.list_dishes()
    render(conn, :index, dishes: dishes)
  end

  def create(conn, %{"dish" => dish_params}) do
    with {:ok, %Dish{} = dish} <- Mensa.create_dish(dish_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/dishes/#{dish}")
      |> render(:show, dish: dish)
    end
  end

  def show(conn, %{"id" => id}) do
    dish = Mensa.get_dish!(id)
    render(conn, :show, dish: dish)
  end

  def update(conn, %{"id" => id, "dish" => dish_params}) do
    dish = Mensa.get_dish!(id)

    with {:ok, %Dish{} = dish} <- Mensa.update_dish(dish, dish_params) do
      render(conn, :show, dish: dish)
    end
  end

  def delete(conn, %{"id" => id}) do
    dish = Mensa.get_dish!(id)

    with {:ok, %Dish{}} <- Mensa.delete_dish(dish) do
      send_resp(conn, :no_content, "")
    end
  end
end
