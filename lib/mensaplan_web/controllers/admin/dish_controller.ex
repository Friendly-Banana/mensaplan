defmodule MensaplanWeb.Admin.DishController do
  use MensaplanWeb, :controller

  alias Mensaplan.Mensa
  alias Mensaplan.Mensa.Dish

  def index(conn, _params) do
    dishes = Mensa.list_dishes()
    render(conn, :index, page_title: "Dishes", dishes: dishes)
  end

  def new(conn, _params) do
    changeset = Mensa.change_dish(%Dish{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"dish" => dish_params}) do
    case Mensa.create_dish(dish_params) do
      {:ok, dish} ->
        conn
        |> put_flash(:info, "Dish created successfully.")
        |> redirect(to: ~p"/admin/dishes/#{dish}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    dish = Mensa.get_dish!(id)
    render(conn, :show, dish: dish)
  end

  def edit(conn, %{"id" => id}) do
    dish = Mensa.get_dish!(id)
    changeset = Mensa.change_dish(dish)
    render(conn, :edit, dish: dish, changeset: changeset)
  end

  def update(conn, %{"id" => id, "dish" => dish_params}) do
    dish = Mensa.get_dish!(id)

    case Mensa.update_dish(dish, dish_params) do
      {:ok, dish} ->
        conn
        |> put_flash(:info, "Dish updated successfully.")
        |> redirect(to: ~p"/admin/dishes/#{dish}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, dish: dish, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    dish = Mensa.get_dish!(id)
    {:ok, _dish} = Mensa.delete_dish(dish)

    conn
    |> put_flash(:info, "Dish deleted successfully.")
    |> redirect(to: ~p"/admin/dishes")
  end
end
