defmodule Mensaplan.UserDataTest do
  use Mensaplan.DataCase

  alias Mensaplan.UserData

  describe "positions" do
    alias Mensaplan.UserData.Position

    import Mensaplan.UserDataFixtures

    @invalid_attrs %{y: nil, x: nil}

    test "list_positions/0 returns all positions" do
      position = position_fixture()
      assert UserData.list_positions() == [position]
    end

    test "get_position!/1 returns the position with given id" do
      position = position_fixture()
      assert UserData.get_position!(position.id) == position
    end

    test "create_position/1 with valid data creates a position" do
      valid_attrs = %{y: 120.5, x: 120.5}

      assert {:ok, %Position{} = position} = UserData.create_position(valid_attrs)
      assert position.y == 120.5
      assert position.x == 120.5
    end

    test "create_position/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserData.create_position(@invalid_attrs)
    end

    test "update_position/2 with valid data updates the position" do
      position = position_fixture()
      update_attrs = %{y: 456.7, x: 456.7}

      assert {:ok, %Position{} = position} = UserData.update_position(position, update_attrs)
      assert position.y == 456.7
      assert position.x == 456.7
    end

    test "update_position/2 with invalid data returns error changeset" do
      position = position_fixture()
      assert {:error, %Ecto.Changeset{}} = UserData.update_position(position, @invalid_attrs)
      assert position == UserData.get_position!(position.id)
    end

    test "delete_position/1 deletes the position" do
      position = position_fixture()
      assert {:ok, %Position{}} = UserData.delete_position(position)
      assert_raise Ecto.NoResultsError, fn -> UserData.get_position!(position.id) end
    end

    test "change_position/1 returns a position changeset" do
      position = position_fixture()
      assert %Ecto.Changeset{} = UserData.change_position(position)
    end
  end
end
