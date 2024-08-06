defmodule Mensaplan.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :avatar, :string
    field :server_id, :integer

    belongs_to :owner, Mensaplan.Accounts.User, on_replace: :nilify

    many_to_many :members, Mensaplan.Accounts.User,
      join_through: "group_members",
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :avatar, :server_id])
    |> cast_assoc(:owner, required: true)
    |> cast_assoc(:members, required: true)
    |> validate_required([:name])
    |> ensure_owner_in_members()
    |> unique_constraint(:server_id)
    |> validate_length(:name, min: 3, max: 30)
  end

  defp ensure_owner_in_members(%Ecto.Changeset{} = changeset) do
    with {_, owner} <- fetch_field(changeset, :owner),
         {_, members} <- fetch_field(changeset, :members) do
      if Enum.member?(members, owner) do
        changeset
      else
        members_with_owner = [owner | members]
        put_change(changeset, :members, members_with_owner)
      end
    else
      :error -> Ecto.Changeset.add_error(changeset, :owner, "Couldn't fetch owner and members")
    end
  end
end
