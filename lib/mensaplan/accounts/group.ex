defmodule Mensaplan.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :avatar, :string

    many_to_many :members, Mensaplan.Accounts.User, join_through: "group_members"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :avatar])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 50)
  end

  def owner(group) do
    group.members[0]
  end
end
