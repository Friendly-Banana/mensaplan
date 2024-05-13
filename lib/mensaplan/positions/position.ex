defmodule TimeUtils do
  def local_time do
    DateTime.now!("Europe/Berlin") 
  end
end

defmodule Mensaplan.Positions.Position do
  use Ecto.Schema
  import Ecto.Changeset
  import TimeUtils

  schema "positions" do
    field :x, :float, default: 0.0
    field :y, :float, default: 0.0
    field :public, :boolean, default: true
    field :expired, :boolean, default: false
    # minutes
    field :expires_in, :integer, default: 60

    belongs_to :owner, Mensaplan.Accounts.User

    timestamps(type: :naive_datetime, default: &local_time/0)
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:x, :y, :public, :expires_in])
    |> validate_required([:x, :y, :owner_id])
    |> cast_assoc(:owner)
    |> validate_number(:x, greater_than_or_equal_to: 0.0, less_than: 100.0)
    |> validate_number(:y, greater_than_or_equal_to: 0.0, less_than: 100.0)
    |> validate_number(:expires_in, greater_than_or_equal_to: 1, less_than_or_equal_to: 60 * 24)
  end
end
