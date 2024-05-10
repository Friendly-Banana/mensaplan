defmodule Mensaplan.UserData.Position do
  use Ecto.Schema
  import Ecto.Changeset

  schema "positions" do
    field :user, :string
    field :x, :float
    field :y, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:x, :y])
    |> validate_required([:user, :x, :y])
    |> unique_constraint(:user)
  end
end
