defmodule Mensaplan.Periodically do
  use GenServer

  import Ecto.Query, warn: false
  import Mensaplan.Helpers
  alias Mensaplan.Mensa
  alias Mensaplan.Mensa.Dish
  alias Mensaplan.Mensa.DishDate
  alias Mensaplan.Positions.Position
  alias Mensaplan.Repo
  require Logger

  @five_minutes 5 * 60 * 1000
  @daily 24 * 60 * 60 * 1000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    Process.send(self(), :fetch_dishes, [])
    Process.send_after(self(), :expire_positions, @five_minutes)
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
    case fetch_dishes() do
      {:ok, message} ->
        Logger.info(message)

      {:error, message} ->
        Logger.error(message)
    end

    now = DateTime.to_time(local_now())
    until_midnight = @daily - elem(Time.to_seconds_after_midnight(now), 0) * 1000
    Process.send_after(self(), :fetch_dishes, until_midnight)
    {:noreply, state}
  end

  def handle_call(:fetch_dishes, _from, state) do
    {:reply, fetch_dishes(), state}
  end

  def fetch_dishes() do
    today = local_now()
    week_number = div(Date.day_of_year(today) - 1, 7) + 1
    week_number = Integer.to_string(week_number, 10) |> String.pad_leading(2, "0")
    Logger.info("Fetching dishes for week #{week_number}...")

    with {:ok, response} <-
           Req.get(
             "https://tum-dev.github.io/eat-api/mensa-garching/#{today.year}/#{week_number}.json"
           ),
         200 <- response.status,
         days when is_list(days) <- response.body["days"] do
      for day_de <- days do
        date = %DishDate{date: Date.from_iso8601!(day_de["date"])}

        for dish_de <- day_de["dishes"] do
          dish =
            Mensa.get_dish_by_name(dish_de["name"]) ||
              dish_from_json(dish_de)
              |> Mensa.change_dish()
              |> Repo.insert_or_update!()

          Map.put(date, :dish_id, dish.id)
          |> Repo.insert!(on_conflict: :nothing)
        end
      end

      {:ok, "Fetched #{Enum.count(days)} days with dishes."}
    else
      {:error, reason} ->
        {:error, "Fetching dishes failed: #{reason}"}

      x ->
        {:ok,
         "Couldn't find data, mensa is probably closed today: #{x}, https://tum-dev.github.io/eat-api/mensa-garching/#{today.year}/#{week_number}.json"}
    end
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
      name_de: String.trim(dish["name"]),
      price:
        ((price["base_price"] > 0 && format(price["base_price"]) <> "€ + ") || "") <>
          per_unit,
      category: dish["dish_type"]
    }
  end
end
