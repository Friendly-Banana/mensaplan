defmodule Mensaplan.PositionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mensaplan.Positions` context.
  """
  alias Mensaplan.AccountsFixtures

  @doc """
  Generate a position.
  """
  def position_fixture(attrs \\ %{}) do
    owner_id =
      attrs[:owner_id] || (attrs[:owner] && attrs[:owner].id) ||
        AccountsFixtures.user_fixture().id

    {:ok, position} =
      attrs
      |> Enum.into(%{
        x: 20.5,
        y: 75.0,
        owner_id: owner_id
      })
      |> Mensaplan.Positions.create_position()

    position
  end
end
