defmodule Mensaplan.MensaTest do
  alias Mensaplan.Mensa.Like
  alias Mensaplan.AccountsFixtures
  use Mensaplan.DataCase

  alias Mensaplan.Mensa

  describe "dishes" do
    alias Mensaplan.Mensa.Dish

    import Mensaplan.MensaFixtures
    import Mensaplan.Helpers

    @invalid_attrs %{category: nil, name: nil, price: nil}

    test "list_dishes/0 returns all dishes" do
      dish = dish_fixture()
      assert Mensa.list_dishes() == [dish]
    end

    test "list_todays_dishes/1 returns all dishes for today" do
      user = AccountsFixtures.user_fixture()
      dish = dish_fixture()
      dish_fixture(date: Date.add(local_now(), -1))
      dish_fixture(date: Date.add(local_now(), 1))
      d = hd(Mensa.list_todays_dishes(user))
      assert d.id == dish.id
      assert d.category == dish.category
      assert d.name == dish.name
      assert d.price == dish.price
    end

    test "list_todays_dishes/1 returns whether the user liked a dish" do
      liked = dish_fixture()
      default = dish_fixture()
      disliked = dish_fixture()

      user = AccountsFixtures.user_fixture()
      Mensa.like_dish(user.id, liked.id)
      Mensa.like_dish(user.id, disliked.id, false)

      dishes = Mensa.list_todays_dishes(user)
      liked = Enum.find(dishes, fn d -> d.id == liked.id end)
      default = Enum.find(dishes, fn d -> d.id == default.id end)
      disliked = Enum.find(dishes, fn d -> d.id == disliked.id end)
      assert liked[:user_likes] == 1
      assert default[:user_likes] == 0
      assert disliked[:user_likes] == -1
    end

    test "list_todays_dishes/1 returns the correct amount of likes" do
      liked = dish_fixture()
      balanced = dish_fixture()
      disliked = dish_fixture()

      user = AccountsFixtures.user_fixture()
      Mensa.like_dish(user.id, liked.id)
      Mensa.like_dish(user.id, balanced.id)
      Mensa.like_dish(user.id, disliked.id, false)

      user2 = AccountsFixtures.user_fixture()
      Mensa.like_dish(user2.id, liked.id)
      Mensa.like_dish(user2.id, balanced.id, false)
      Mensa.like_dish(user2.id, disliked.id, false)

      dishes = Mensa.list_todays_dishes(user)
      assert length(dishes) == 3
      liked = Enum.find(dishes, fn d -> d.id == liked.id end)
      balanced = Enum.find(dishes, fn d -> d.id == balanced.id end)
      disliked = Enum.find(dishes, fn d -> d.id == disliked.id end)
      assert liked[:likes] == 2
      assert balanced[:likes] == 0
      assert disliked[:likes] == -2
    end

    test "get_dish!/1 returns the dish with given id" do
      dish = dish_fixture()
      assert Mensa.get_dish!(dish.id) == dish
    end

    test "create_dish/1 with valid data creates a dish" do
      valid_attrs = %{
        category: "some category",
        name: "some name",
        price: "some price",
        date: local_now()
      }

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
      tomorrow = local_now() |> Date.add(1)

      update_attrs = %{
        category: "some updated category",
        name: "some updated name",
        price: "some updated price",
        date: tomorrow
      }

      assert {:ok, %Dish{} = dish} = Mensa.update_dish(dish, update_attrs)
      assert dish.category == "some updated category"
      assert dish.name == "some updated name"
      assert dish.price == "some updated price"
      assert dish.date == tomorrow
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

    defp equal_like?(like1, like2) do
      like1.user_id == like2.user_id and like1.dish_id == like2.dish_id and
        like1.like == like2.like
    end

    test "like_dish/3 likes a dish" do
      dish = dish_fixture()
      user = AccountsFixtures.user_fixture()

      Mensa.like_dish(user.id, dish.id)
      like = %Like{user_id: user.id, dish_id: dish.id, like: 1}
      dish = Mensa.get_dish!(dish.id) |> Repo.preload(:likes)
      assert equal_like?(hd(dish.likes), like)

      Mensa.like_dish(user.id, dish.id, false)
      dislike = %Like{user_id: user.id, dish_id: dish.id, like: -1}
      dish = Mensa.get_dish!(dish.id) |> Repo.preload(:likes)
      assert equal_like?(hd(dish.likes), dislike)
    end

    test "unlike_dish/3 removes all votes on a dish" do
      dish = dish_fixture()
      user = AccountsFixtures.user_fixture()
      Mensa.like_dish(user.id, dish.id)
      Mensa.unlike_dish(user.id, dish.id)
      dish = Mensa.get_dish!(dish.id) |> Repo.preload(:likes)
      assert dish.likes == []
    end
  end
end
