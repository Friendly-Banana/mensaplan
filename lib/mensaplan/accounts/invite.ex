defmodule Mensaplan.Accounts.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: true}
  schema "invites" do
    belongs_to :inviter, Mensaplan.Accounts.User
    belongs_to :group, Mensaplan.Accounts.Group

    timestamps()
  end

  @doc false
  def changeset(invite, _attrs) do
    invite
    |> cast_assoc(:inviter, required: true)
    |> cast_assoc(:group, required: true)
  end
end
