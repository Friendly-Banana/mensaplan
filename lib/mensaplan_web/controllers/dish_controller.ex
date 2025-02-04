defmodule MensaplanWeb.DishController do
  use MensaplanWeb, :controller

  alias Mensaplan.Mensa.Dish
  alias Mensaplan.Mensa

  def show(conn, %{"id" => id}) do
    dish = Mensa.get_dish!(id)
    name = Dish.get_locale_name(dish)
    served_dates = Mensa.get_dates_for_dish!(dish.id)

    render(conn,
      page_title: name,
      dish: dish,
      served_dates: served_dates
    )
  end
end
