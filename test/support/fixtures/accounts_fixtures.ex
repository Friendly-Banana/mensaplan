defmodule Mensaplan.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mensaplan.Accounts` context.
  """

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
  def group_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, group} =
      Mensaplan.Accounts.create_group(
        user,
        Enum.into(attrs, %{
          avatar: "some avatar",
          name: "some name"
        })
      )

    group
  end
end
