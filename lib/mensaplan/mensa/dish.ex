defmodule Mensaplan.Mensa.Dish do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dishes" do
    field :name, :string
    field :price, :string
    field :category, :string
    field :date, :date, default: Date.utc_today()

    has_many :likes, Mensaplan.Mensa.Like
  end

  @doc false
  def changeset(dish, attrs) do
    dish
    |> cast(attrs, [:name, :price, :category])
    |> validate_required([:name, :price, :category])
  end
end
