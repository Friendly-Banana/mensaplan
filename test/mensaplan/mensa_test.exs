defmodule Mensaplan.MensaTest do
  use Mensaplan.DataCase

  alias Mensaplan.Mensa

  describe "dishes" do
    alias Mensaplan.Mensa.Dish

    import Mensaplan.MensaFixtures

    @invalid_attrs %{category: nil, name: nil, price: nil}

    test "list_dishes/0 returns all dishes" do
      dish = dish_fixture()
      assert Mensa.list_dishes() == [dish]
    end

    test "get_dish!/1 returns the dish with given id" do
      dish = dish_fixture()
      assert Mensa.get_dish!(dish.id) == dish
    end

    test "create_dish/1 with valid data creates a dish" do
      valid_attrs = %{category: "some category", name: "some name", price: "some price"}

      assert {:ok, %Dish{} = dish} = Mensa.create_dish(valid_attrs)
      assert dish.category == "some category"
      assert dish.name == "some name"
      assert dish.price == "some price"
    end

    test "create_dish/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mensa.create_dish(@invalid_attrs)
    end

    test "update_dish/2 with valid data updates the dish" do
      dish = dish_fixture()
      update_attrs = %{category: "some updated category", name: "some updated name", price: "some updated price"}

      assert {:ok, %Dish{} = dish} = Mensa.update_dish(dish, update_attrs)
      assert dish.category == "some updated category"
      assert dish.name == "some updated name"
      assert dish.price == "some updated price"
    end

    test "update_dish/2 with invalid data returns error changeset" do
      dish = dish_fixture()
      assert {:error, %Ecto.Changeset{}} = Mensa.update_dish(dish, @invalid_attrs)
      assert dish == Mensa.get_dish!(dish.id)
    end

    test "delete_dish/1 deletes the dish" do
      dish = dish_fixture()
      assert {:ok, %Dish{}} = Mensa.delete_dish(dish)
      assert_raise Ecto.NoResultsError, fn -> Mensa.get_dish!(dish.id) end
    end

    test "change_dish/1 returns a dish changeset" do
      dish = dish_fixture()
      assert %Ecto.Changeset{} = Mensa.change_dish(dish)
    end
  end
end
