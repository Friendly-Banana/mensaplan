defmodule Mensaplan.Mensa.DishDate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "dish_dates" do
    field :date, :date
    belongs_to :dish, Mensaplan.Mensa.Dish
  end

  @doc false
  def changeset(dish_date, attrs) do
    dish_date
    |> cast(attrs, [:date])
    |> validate_required([:date])
    |> cast_assoc(:dish, required: true)
    |> assoc_constraint(:dish)
  end
end
