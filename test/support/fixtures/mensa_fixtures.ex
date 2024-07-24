defmodule Mensaplan.MensaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mensaplan.Mensa` context.
  """

  @doc """
  Generate a dish.
  """
  def dish_fixture(attrs \\ %{}) do
    {:ok, dish} =
      attrs
      |> Enum.into(%{
        category: "some category",
        name: "some name",
        price: "some price"
      })
      |> Mensaplan.Mensa.create_dish()

    dish
  end
end