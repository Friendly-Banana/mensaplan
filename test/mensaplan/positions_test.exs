defmodule Mensaplan.PositionsTest do
  use Mensaplan.DataCase

  alias Mensaplan.AccountsFixtures
  alias Mensaplan.Positions

  describe "positions" do
    alias Mensaplan.Positions.Position

    import Mensaplan.PositionsFixtures

    @invalid_attrs %{y: nil, x: nil}

    test "list_positions/0 returns all positions" do
      position = position_fixture()
      assert hd(Positions.list_positions()).id == position.id
    end

    test "list_positions_for_server/1 returns all positions for server" do
      user = AccountsFixtures.user_fixture()
      group = AccountsFixtures.group_fixture(%{server_id: 1}, owner: user)
      position = position_fixture(%{owner_id: user.id})

      pos = %{id: position.id, name: user.name, avatar: user.avatar, x: position.x, y: position.y}

      assert Positions.list_positions_for_server(group.server_id) == [pos]
    end

    test "get_position!/1 returns the position with given id" do
      position = position_fixture()
      assert Positions.get_position!(position.id).id == position.id
    end

    test "get_public_positions/0 returns all public positions" do
      position_fixture(%{public: false})
      position = position_fixture(public: true)
      assert hd(Positions.get_public_positions()).id == position.id
    end

    test "get_position_of_user/1 returns the position of the user" do
      user = AccountsFixtures.user_fixture()
      position = position_fixture(%{owner_id: user.id})
      assert Positions.get_position_of_user(user).id == position.id
    end

    test "get_position_of_user/1 returns nil if user has no position" do
      user = AccountsFixtures.user_fixture()
      assert Positions.get_position_of_user(user) == nil
    end

    test "get_positions_visible_to_user/1 returns all positions visible to user" do
      user = AccountsFixtures.user_fixture()
      user2 = AccountsFixtures.user_fixture()
      _common_group = AccountsFixtures.group_fixture(%{}, owner: user, members: [user, user2])
      position = position_fixture(%{public: true})
      position1 = position_fixture(%{public: false, owner_id: user.id})
      position2 = position_fixture(%{public: false, owner_id: user2.id})
      position_fixture(%{public: false})

      assert Enum.all?(Positions.get_positions_visible_to_user(user), fn p ->
               Enum.member?([position.id, position1.id, position2.id], p.id)
             end)
    end

    test "create_position/1 with valid data creates a position" do
      user = AccountsFixtures.user_fixture()
      valid_attrs = %{y: 20.5, x: 75.0, owner_id: user.id}

      assert {:ok, %Position{} = position} = Positions.create_position(valid_attrs)
      assert position.y == 20.5
      assert position.x == 75.0
    end

    test "create_position/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Positions.create_position(@invalid_attrs)
    end

    test "delete_position/1 deletes the position" do
      position = position_fixture()
      assert {:ok, %Position{}} = Positions.delete_position(position)
      assert_raise Ecto.NoResultsError, fn -> Positions.get_position!(position.id) end
    end

    test "expire_all_positions/1 expires all positions of a user" do
      user = AccountsFixtures.user_fixture()
      position = position_fixture(%{owner_id: user.id})
      position1 = position_fixture(%{owner_id: user.id})
      position2 = position_fixture(%{owner_id: user.id, expired: true})

      user2 = AccountsFixtures.user_fixture()
      other_position = position_fixture(%{owner_id: user2.id})

      Positions.expire_all_positions(user.id)

      positions = Repo.reload([position, position1, position2])
      other_position = Repo.reload(other_position)

      assert Enum.all?(positions, fn p -> p.expired end)
      assert other_position.expired == false
    end

    test "change_position/1 returns a position changeset" do
      position = position_fixture()
      assert %Ecto.Changeset{} = Positions.change_position(position)
    end
  end
end
