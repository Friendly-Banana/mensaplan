defmodule Mensaplan.MensaTest do
  alias Mensaplan.Mensa.Like
  alias Mensaplan.AccountsFixtures
  use Mensaplan.DataCase

  alias Mensaplan.Mensa

  describe "dishes" do
    alias Mensaplan.Mensa.Dish

    import Mensaplan.Helpers
    import Mensaplan.MensaFixtures

    @invalid_attrs %{category: nil, name_de: nil, name_en: nil, fixed_price: nil, price_per_unit: nil}

    test "list_dishes/0 returns all dishes" do
      dish = dish_fixture()
      assert Mensa.list_dishes() == [dish]
    end

    test "list_dishes/2 returns the correct amount of likes" do
      liked = dish_fixture()
      ignored = dish_fixture()
      disliked = dish_fixture()

      user = AccountsFixtures.user_fixture()
      Mensa.like_dish(user.id, liked.id)
      Mensa.like_dish(user.id, disliked.id, false)

      user2 = AccountsFixtures.user_fixture()
      Mensa.like_dish(user2.id, liked.id)
      Mensa.like_dish(user2.id, ignored.id, false)
      Mensa.like_dish(user2.id, disliked.id, false)

      dishes = Mensa.list_dishes(user, fn q -> q end)
      assert length(dishes) == 3
      liked = Enum.find(dishes, fn d -> d.id == liked.id end)
      ignored = Enum.find(dishes, fn d -> d.id == ignored.id end)
      disliked = Enum.find(dishes, fn d -> d.id == disliked.id end)
      assert liked[:likes] == 2
      assert ignored[:likes] == -1
      assert disliked[:likes] == -2

      assert liked[:user_likes] > 0
      assert ignored[:user_likes] == 0
      assert disliked[:user_likes] < 0
    end

    test "list_todays_dishes/1 returns all dishes for today" do
      user = AccountsFixtures.user_fixture()
      today = dish_fixture()
      yesterday = dish_fixture()
      tomorrow = dish_fixture()
      Mensa.add_date_to_dish!(today, DateTime.to_date(local_now()))
      Mensa.add_date_to_dish!(yesterday, Date.add(local_now(), -1))
      Mensa.add_date_to_dish!(tomorrow, Date.add(local_now(), 1))
      d = hd(Mensa.list_todays_dishes(user))
      assert d.id == today.id
    end

    test "get_dish!/1 returns the dish with given id" do
      dish = dish_fixture()
      assert Mensa.get_dish!(dish.id) == dish
    end

    test "create_dish/1 with valid data creates a dish" do
      valid_attrs = %{
        category: "some category",
        name_de: "some name_de",
        name_en: "some name_en",
        fixed_price: 1,
        price_per_unit: 2
      }

      assert {:ok, %Dish{} = dish} = Mensa.create_dish(valid_attrs)
      assert dish.category == "some category"
      assert dish.name_de == "some name_de"
      assert dish.name_en == "some name_en"
      assert dish.fixed_price == 1
      assert dish.price_per_unit == 2
    end

    test "create_dish/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mensa.create_dish(@invalid_attrs)
    end

    test "update_dish/2 with valid data updates the dish" do
      dish = dish_fixture()

      update_attrs = %{
        category: "some updated category",
        name_de: "some updated name_de",
        name_en: "some updated name_en",
        fixed_price: 3,
        price_per_unit: 4

      }

      assert {:ok, %Dish{} = dish} = Mensa.update_dish(dish, update_attrs)
      assert dish.category == "some updated category"
      assert dish.name_de == "some updated name_de"
      assert dish.name_en == "some updated name_en"
      assert dish.fixed_price == 3
      assert dish.price_per_unit == 4
    end

    test "update_dish/2 with invalid data returns error changeset" do
      dish = dish_fixture()
      assert {:error, %Ecto.Changeset{}} = Mensa.update_dish(dish, @invalid_attrs)
      assert dish == Mensa.get_dish!(dish.id)
    end

    test "add_date_to_dish/2 adds a date to the dish" do
      dish = dish_fixture()
      date = Date.utc_today()
      assert Mensa.add_date_to_dish!(dish, date)
      dish = Mensa.get_dish!(dish.id) |> Repo.preload(:dish_dates)
      assert date == hd(dish.dish_dates).date
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
