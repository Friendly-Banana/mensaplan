defmodule Mensaplan.MensaTest do
  alias Mensaplan.Mensa.Like
  alias Mensaplan.AccountsFixtures
  use Mensaplan.DataCase

  alias Mensaplan.Mensa

  describe "dishes" do
    alias Mensaplan.Mensa.Dish

    import Mensaplan.MensaFixtures
    import TimeUtils

    @invalid_attrs %{category: nil, name: nil, price: nil}

    test "list_dishes/0 returns all dishes" do
      dish = dish_fixture()
      assert Mensa.list_dishes() == [dish]
    end

    test "list_todays_dishes/1 returns all dishes for today" do
      dish = dish_fixture()
      dish_fixture(date: Date.add(local_now(), -1))
      dish_fixture(date: Date.add(local_now(), 1))
      d = Mensa.list_todays_dishes(nil)[0]
      assert d.id == dish.id
      assert d.category == dish.category
      assert d.name == dish.name
      assert d.price == dish.price
    end

    test "list_todays_dishes/1 returns the correct amount of likes" do
      Repo.delete_all(from _ in Dish)
      dish = dish_fixture()
      dish2 = dish_fixture()
      dish3 = dish_fixture()

      user = AccountsFixtures.user_fixture()
      Mensa.like_dish(user.id, dish.id)
      Mensa.like_dish(user.id, dish2.id)
      Mensa.like_dish(user.id, dish3.id, false)

      user2 = AccountsFixtures.user_fixture()
      Mensa.like_dish(user2.id, dish.id)
      Mensa.like_dish(user2.id, dish.id, false)
      Mensa.like_dish(user2.id, dish3.id, false)

      dishes = Mensa.list_todays_dishes(user)
      assert length(dishes) == 3
      assert dishes[0][:user_likes] == 2
      assert dishes[1][:user_likes] == 0
      assert dishes[2][:user_likes] == -2
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

      update_attrs = %{
        category: "some updated category",
        name: "some updated name",
        price: "some updated price"
      }

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

    test "like_dish/3 likes a dish" do
      dish = dish_fixture()
      user = AccountsFixtures.user_fixture()

      Mensa.like_dish(user.id, dish.id)
      like = %Like{user_id: user.id, dish_id: dish.id, like: 1}
      assert Mensa.get_dish!(dish.id).likes == [like]

      Mensa.like_dish(user.id, dish.id, false)
      dislike = %Like{user_id: user.id, dish_id: dish.id, like: -1}
      assert Mensa.get_dish!(dish.id).likes == [dislike]
    end

    test "unlike_dish/3 removes all votes on a dish" do
      dish = dish_fixture()
      user = AccountsFixtures.user_fixture()
      Mensa.like_dish(user.id, dish.id)
      Mensa.unlike_dish(user.id, dish.id)
      assert Mensa.get_dish!(dish.id).likes == []
    end
  end
end
