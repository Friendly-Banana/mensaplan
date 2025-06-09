defmodule MensaplanWeb.DishesLive do
  require Logger

  import Ecto.Query, warn: false

  use MensaplanWeb, :live_view
  use Gettext, backend: MensaplanWeb.Gettext
  alias Mensaplan.Mensa

  @categories [
    "Pasta",
    "Pizza",
    "Grill",
    "Wok",
    "Studitopf",
    "Fleisch",
    "Vegetarisch/fleischlos",
    "Vegan",
    "Tagessupe, Brot, Obst",
    "Dessert (Glas)",
    "Beilagen",
    "Salat",
    "Obst",
    "Fisch",
    "Süßspeise",
    "Special"
  ]

  @impl true
  def mount(%{"locale" => locale}, session, socket) do
    Gettext.put_locale(locale)

    user = session["user"]
    socket = assign(socket, user: user, page_title: gettext("Dishes"))

    {:ok, socket}
  end

  def get_dishes(user, category, sort) do
    Mensa.list_dishes(user, fn q -> sort_and_filter(q, category, sort) end)
  end

  def sort_and_filter(query, category, sort) do
    query =
      if(Enum.member?(@categories, category),
        do: query |> where(category: ^category),
        else: query
      )

    case sort do
      "likes" ->
        query |> order_by(desc: fragment("likes"))

      "price_asc" ->
        query |> order_by(asc: :fixed_price, asc: :price_per_unit)

      "price_desc" ->
        query |> order_by(desc: :fixed_price, desc: :price_per_unit)

      "amount" ->
        from d in query,
          order_by: [
            desc: fragment("(SELECT count(*) FROM dish_dates WHERE ? = dish_dates.dish_id)", d.id)
          ]

      _ ->
        name = if Gettext.get_locale(MensaplanWeb.Gettext) == "en", do: :name_en, else: :name_de
        query |> order_by(asc: ^name)
    end
  end

  @impl true
  def handle_params(params, _, socket) do
    category = Map.get(params, "category")
    sort = Map.get(params, "sort")

    {:noreply,
     assign(socket, category: category, sort: sort)
     |> stream(:dishes, get_dishes(socket.assigns.user, category, sort), reset: true)}
  end

  @impl true
  def handle_event("apply", %{"category" => category, "sort" => sort}, socket) do
    {:noreply,
     assign(socket, category: category, sort: sort)
     |> push_patch(
       to:
         "/" <>
           Gettext.get_locale(MensaplanWeb.Gettext) <> "/dishes?category=#{category}&sort=#{sort}"
     )}
  end

  @impl true
  def handle_info({:update_dish, dish_id}, socket) do
    {:noreply, stream_insert(socket, :dishes, Mensa.single_dish(socket.assigns.user, dish_id))}
  end
end
