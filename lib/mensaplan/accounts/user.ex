defmodule Mensaplan.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :auth_id, :string
    field :name, :string
    field :email, :string
    field :avatar, :string
    field :default_public, :boolean, default: true

    many_to_many :groups, Mensaplan.Accounts.Group, join_through: "group_members"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:auth_id, :name, :email, :avatar, :default_public])
    |> validate_required([:auth_id, :name, :avatar])
    |> validate_length(:name, min: 1, max: 100)
  end

  @doc """
  Changes the settings of a user. This must not allow id, name or anything sensible as parameters.
  """
  def change_settings(user, attrs) do
    user
    |> cast(attrs, [:default_public])
    |> validate_required([:default_public])
  end
end
