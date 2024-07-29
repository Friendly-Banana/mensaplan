defmodule Mensaplan.AccountsTest do
  use Mensaplan.DataCase

  alias Mensaplan.Accounts
  import Mensaplan.AccountsFixtures

  describe "users" do
    alias Mensaplan.Accounts.User

    @invalid_attrs %{auth_id: nil, avatar: nil, default_public: nil, name: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_auth_id/1 returns the user with given auth_id" do
      user = user_fixture()
      assert Accounts.get_user_by_auth_id("some auth_id") == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        auth_id: "some auth_id",
        avatar: "some avatar",
        default_public: true,
        name: "some name"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.auth_id == "some auth_id"
      assert user.avatar == "some avatar"
      assert user.default_public == true
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        auth_id: "some updated auth_id",
        avatar: "some updated avatar",
        default_public: false,
        name: "some updated name"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.auth_id == "some updated auth_id"
      assert user.avatar == "some updated avatar"
      assert user.default_public == false
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user_settings/2 only allows changing settings" do
      user = user_fixture()

      update_attrs = %{
        auth_id: "some updated auth_id",
        avatar: "some updated avatar",
        default_public: false,
        name: "some updated name"
      }

      assert {:ok, %User{} = user} = Accounts.update_user_settings(user, update_attrs)
      assert user.auth_id == "some auth_id"
      assert user.avatar == "some avatar"
      assert user.default_public == false
      assert user.name == "some name"
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "groups" do
    alias Mensaplan.Accounts.Group

    @invalid_attrs %{avatar: nil, name: nil}

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Accounts.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Accounts.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      valid_attrs = %{avatar: "some avatar", name: "some name"}

      assert {:ok, %Group{} = group} = Accounts.create_group(valid_attrs)
      assert group.avatar == "some avatar"
      assert group.name == "some name"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      user = user_fixture()
      group = group_fixture()

      update_attrs = %{
        avatar: "some updated avatar",
        name: "some updated name",
        owner: user,
        members: [user]
      }

      assert {:ok, %Group{} = group} = Accounts.update_group(group, update_attrs)
      assert group.avatar == "some updated avatar"
      assert group.name == "some updated name"
      assert group.owner == user
      assert group.members == [user]
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_group(group, @invalid_attrs)
      assert group == Accounts.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Accounts.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Accounts.change_group(group)
    end

    test "owner is always in members" do
      user = user_fixture()
      group = group_fixture(owner: user)
      assert group.members == [user]
    end

    test "add_user_to_group/2 adds user into members" do
      user = user_fixture()
      group = group_fixture()
      assert {:ok, %Group{} = group} = Accounts.add_user_to_group(group, user)
      assert group.members == [user]
    end

    test "remove_user_from_group/2 removes last user from members, deletes group" do
      user = user_fixture()
      group = group_fixture(owner: user, members: [user])
      assert {:ok, %Group{} = group} = Accounts.remove_user_from_group(group, user)
      assert group.members == []
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_group!(group.id) end
    end

    test "remove_user_from_group/2 removes user from members, transfers ownership" do
      user = user_fixture()
      user2 = user_fixture()
      group = group_fixture(owner: user, members: [user, user2])
      assert {:ok, %Group{} = group} = Accounts.remove_user_from_group(group, user)
      assert group.owner == user2
      assert group.members == [user2]
    end
  end

  describe "invites" do
    alias Mensaplan.Accounts.Invite

    test "create_invite/2 with valid data creates an invite" do
      user = user_fixture()
      group = group_fixture()
      assert {:ok, %Accounts.Invite{} = invite} = Accounts.create_invite(user, group)
      assert invite.inviter == user
      assert invite.group == group
    end

    test "create_invite/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_invite(nil, nil)
    end

    test "fetch_invite!/1 returns the invite with given id" do
      user = user_fixture()
      group = group_fixture()
      invite = Accounts.create_invite(user, group)
      assert Accounts.fetch_invite(invite.uuid) == invite
    end

    test "accept_invite/2 adds user to group, deletes invite" do
      user = user_fixture()
      group = group_fixture()
      invite = Accounts.create_invite(user, group)
      assert {:ok, %Accounts.Invite{}} = Accounts.accept_invite(invite)
      assert group.members == [user]
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_invite!(invite.id) end
    end
  end
end
