defmodule Mensaplan.Mensa.Like do
  use Ecto.Schema

  @primary_key false
  schema "likes" do
    field :like, :integer

    belongs_to :user, Mensaplan.Accounts.User, primary_key: true
    belongs_to :dish, Mensaplan.Mensa.Dish, primary_key: true
  end
end
