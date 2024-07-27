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
  @timezone "Europe/Berlin"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Process.send_after(self(), :expire_positions, @five_minutes)
    # run shortly after midnight
    {:ok, now} = DateTime.now(@timezone)
    till_midnight = Time.diff(~T[00:00:00], now, :millisecond)
    Process.send_after(self(), :fetch_dishes, @daily + @five_minutes + till_midnight)
    {:ok, state}
  end

  def handle_info(:expire_positions, state) do
    Logger.debug("Expiring positions...")

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
    {:ok, today} = DateTime.now(@timezone)
    week_number = div(Date.day_of_year(today) - 1, 7) + 1
    Logger.info("Fetching dishes for #{today}...")

    with {:ok, response} <-
           Req.get(
             "https://tum-dev.github.io/eat-api/mensa-garching/#{today.year}/#{week_number}.json"
           ),
         day when day != nil <-
           Enum.find(response.body["days"], fn day -> day["date"] == Date.to_iso8601(today) end),
         dishes when dishes != nil <- day["dishes"] do
      dishes = Enum.filter(dishes, fn dish -> dish["dish_type"] != "Beilagen" end)

      Enum.map(dishes, &dish_from_json/1)
      |> Enum.each(fn dish ->
        (Mensa.get_dish_by_name(dish.name) || dish)
        |> Dish.changeset(%{date: today})
        |> Repo.insert_or_update()
      end)

      Logger.info("Fetched #{Enum.count(dishes)} dishes.")
    else
      nil ->
        Logger.info("Couldn't find data, mensa is probably closed today.")

      {:error, reason} ->
        Logger.error("Fetching dishes failed: #{reason}")
    end

    Process.send_after(self(), :fetch_dishes, @daily)
    {:noreply, state}
  end

  def format(num) when is_integer(num) do
    :erlang.integer_to_binary(num) <> ".00"
  end

  def format(num) when is_float(num) do
    :erlang.float_to_binary(num, decimals: 2)
  end

  def dish_from_json(dish) do
    price = dish["prices"]["students"]
    per_unit = format(price["price_per_unit"]) <> "€/" <> price["unit"]

    %Dish{
      name: String.trim(dish["name"]),
      price:
        ((price["base_price"] > 0 && format(price["base_price"]) <> "€ + ") || "") <>
          per_unit,
      category: dish["dish_type"]
    }
  end
end
