defmodule MensaplanWeb.DishController do
  use MensaplanWeb, :controller

  alias Mensaplan.Mensa.Dish
  alias Mensaplan.Mensa
  import Mensaplan.Helpers

  def show(conn, %{"id" => id} = params) do
    dish = Mensa.get_dish!(id)
    name = Dish.get_locale_name(dish)
    served_dates = Mensa.get_dates_for_dish!(dish.id)

    today = local_now()

    date =
      with true <- is_map_key(params, "date"),
           {:ok, date} <- Date.from_iso8601(params["date"]) do
        date
      else
        _ -> today
      end

    render(conn, :show,
      page_title: name,
      dish: dish,
      served_dates: served_dates,
      date: date,
      today: today
    )
  end
end
