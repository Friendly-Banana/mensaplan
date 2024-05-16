defmodule Mensaplan.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :avatar, :string

    belongs_to :owner, Mensaplan.Accounts.User
    many_to_many :members, Mensaplan.Accounts.User, join_through: "group_members"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :avatar])
    |> cast_assoc(attrs, [:owner, :members])
    |> validate_required([:name, :owner])
    # todo ensure owner is in members
    |> validate_length(:name, min: 3, max: 50)
  end
end
