defmodule Mensaplan.Periodically do
  use GenServer

  import Ecto.Query, warn: false
  alias Mensaplan.Mensa
  alias Mensaplan.Mensa.Dish
  alias Mensaplan.Positions.Position
  alias Mensaplan.Repo
  require Logger

  @five_minutes 5 * 60 * 1000
  @daily 24 * 60 * 60 * 1000

  def format(num) when is_integer(num) do
    :erlang.integer_to_binary(num) <> ".00"
  end

  def format(num) when is_float(num) do
    :erlang.float_to_binary(num, decimals: 2)
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Process.send_after(self(), :expire_positions, @five_minutes)
    Process.send_after(self(), :fetch_dishes, 0)
    {:ok, state}
  end

  def handle_info(:expire_positions, state) do
    Logger.info("Expiring positions...")

    from(p in Position,
      where:
        not p.expired and
          fragment(
            "? + interval '1 minute' * ? <= NOW() AT TIME ZONE 'UTC'",
            p.inserted_at,
            p.expires_in
          )
    )
    |> Repo.update_all(set: [expired: true, updated_at: DateTime.utc_now()])

    # Reschedule once more
    Process.send_after(self(), :expire_positions, @five_minutes)
    {:noreply, state}
  end

  def handle_info(:fetch_dishes, state) do
    Logger.info("Fetching dishes...")

    today = Date.utc_today()
    today = Date.add(today, -3)
    week_number = div(Date.day_of_year(today) - 1, 7) + 1

    with {:ok, response} <-
           Req.get(
             "https://tum-dev.github.io/eat-api/en/mensa-garching/#{today.year}/#{week_number}.json"
           ),
         day <-
           Enum.find(response.body["days"], fn day -> day["date"] == Date.to_iso8601(today) end),
         dishes <- day["dishes"] do
      Enum.map(dishes, fn dish ->
        price = dish["prices"]["students"]
        per_unit = format(price["price_per_unit"]) <> "€/" <> price["unit"]

        %Dish{
          name: String.trim(dish["name"]),
          price:
            ((price["base_price"] > 0 && format(price["base_price"]) <> "€ + ") || "") <>
              per_unit,
          category: dish["dish_type"]
        }
      end)
      |> Enum.filter(fn dish -> dish.category != "Beilagen" end)
      |> Enum.each(fn dish ->
        (Mensa.get_dish_by_name(dish.name) || dish)
        |> Dish.changeset(%{})
        |> Repo.insert_or_update()
      end)
    else
      {:error, reason} ->
        Logger.error("Fetching dishes failed: #{reason}")
    end

    Process.send_after(self(), :fetch_dishes, @daily)
    {:noreply, state}
  end
end
