defmodule Mensaplan.Mensa.Dish do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dishes" do
    field :category, :string
    field :name, :string
    field :price, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dish, attrs) do
    dish
    |> cast(attrs, [:name, :price, :category])
    |> validate_required([:name, :price, :category])
  end
end
