defmodule Mensaplan.PositionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mensaplan.Positions` context.
  """

  @doc """
  Generate a position.
  """
  def position_fixture(attrs \\ %{}) do
    {:ok, position} =
      attrs
      |> Enum.into(%{
        x: 20.5,
        y: 75.0
      })
      |> Mensaplan.Positions.create_position()

    position
  end
end
