defmodule Mensaplan.Mensa.Dish do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dishes" do
    field :name_de, :string
    field :name_en, :string
    field :fixed_price, :integer
    field :price_per_unit, :integer
    field :category, :string

    has_many :dish_dates, Mensaplan.Mensa.DishDate
    has_many :likes, Mensaplan.Mensa.Like
  end

  def get_locale_name(dish) do
    (Gettext.get_locale(MensaplanWeb.Gettext) == "en" && dish.name_en) || dish.name_de
  end

  @doc false
  def changeset(dish, attrs) do
    dish
    |> cast(attrs, [:name_de, :name_en, :fixed_price, :price_per_unit, :category])
    |> validate_required([:name_de, :fixed_price, :price_per_unit, :category])
  end
end
