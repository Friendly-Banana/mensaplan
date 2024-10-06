defmodule Mensaplan.Mensa.Dish do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dishes" do
    field :name_de, :string
    field :name_en, :string
    field :price, :string
    field :category, :string

    has_many :dish_dates, Mensaplan.Mensa.DishDate
    has_many :likes, Mensaplan.Mensa.Like
  end

  @doc false
  def changeset(dish, attrs) do
    dish
    |> cast(attrs, [:name_de, :name_en, :price, :category])
    |> validate_required([:name_de, :price, :category])
  end
end
