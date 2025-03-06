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
        name_de: "some name_de #{System.unique_integer()}",
        name_en: "some name_en",
        fixed_price: 100,
        price_per_unit: 80
      })
      |> Mensaplan.Mensa.create_dish()

    dish
  end
end
