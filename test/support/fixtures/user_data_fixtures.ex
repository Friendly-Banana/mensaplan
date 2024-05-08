defmodule Mensaplan.UserDataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mensaplan.UserData` context.
  """

  @doc """
  Generate a position.
  """
  def position_fixture(attrs \\ %{}) do
    {:ok, position} =
      attrs
      |> Enum.into(%{
        x: 120.5,
        y: 120.5
      })
      |> Mensaplan.UserData.create_position()

    position
  end
end
