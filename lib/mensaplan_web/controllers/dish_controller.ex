defmodule MensaplanWeb.DishController do
  use MensaplanWeb, :controller

  alias Mensaplan.Mensa.Dish
  alias Mensaplan.Mensa
  import Mensaplan.Helpers

  def show(conn, %{"id" => id} = params) do
    dish = Mensa.get_dish!(id)
    name = Dish.get_locale_name(dish)
    dates = Mensa.get_dates_for_dish!(dish.id)

    today =
      with true <- is_map_key(params, "date"),
           {:ok, date} <- Date.from_iso8601(params["date"]) do
        date
      else
        _ -> local_now()
      end

    render(conn, :show, page_title: name, dish: dish, dates: dates, today: today)
  end
end
