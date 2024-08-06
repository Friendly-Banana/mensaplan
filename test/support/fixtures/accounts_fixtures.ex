defmodule Mensaplan.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mensaplan.Accounts` context.
  """
  alias Mensaplan.Accounts.Group

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        auth_id: "some auth_id #{System.unique_integer()}",
        avatar: "some avatar",
        default_public: true,
        name: "some name"
      })
      |> Mensaplan.Accounts.create_user()

    user
  end

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}, opts \\ []) do
    owner = Keyword.get(opts, :owner, user_fixture())
    members = Keyword.get(opts, :members, [owner])

    Ecto.Changeset.change(%Group{})
    |> Ecto.Changeset.put_assoc(:owner, owner)
    |> Ecto.Changeset.put_assoc(:members, members)
    |> Group.changeset(
      Enum.into(attrs, %{
        avatar: "some avatar",
        name: "some name"
      })
    )
    |> Mensaplan.Repo.insert!()
  end
end
