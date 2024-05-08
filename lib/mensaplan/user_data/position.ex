defmodule Mensaplan.UserData.Position do
  use Ecto.Schema
  import Ecto.Changeset

  schema "positions" do
    field :y, :float
    field :x, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:x, :y])
    |> validate_required([:x, :y])
  end
end
