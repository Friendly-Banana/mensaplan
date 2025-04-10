defmodule Mensaplan.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias Mensaplan.Accounts.Group
  alias Mensaplan.Accounts.Invite
  alias Mensaplan.Repo

  alias Mensaplan.Accounts.User

  def fetch_invite(uuid) do
    Repo.one(from i in Invite, where: i.uuid == ^uuid, preload: [:group, :inviter])
  end

  def create_invite(%User{} = creator, %Group{} = group) do
    %Invite{}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:inviter, creator)
    |> Ecto.Changeset.put_assoc(:group, group)
    |> Repo.insert()
  end

  def accept_invite(%User{} = user, uuid) do
    Repo.transaction(fn ->
      invite = Repo.one!(from i in Invite, where: i.uuid == ^uuid, preload: [:group])

      add_user_to_group(user, invite.group)

      invite |> Repo.delete!()
    end)
  end

  def add_user_to_group(%User{} = user, %Group{} = group) do
    group = Repo.preload(group, [:owner, :members])

    if !Enum.member?(group.members, user) do
      change_group(group)
      |> Ecto.Changeset.put_assoc(:members, [user | group.members])
      |> Repo.update!()
    end
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_auth_id(auth_id), do: Repo.get_by(User, auth_id: auth_id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # update the user in case the name or avatar has changed
  def create_or_update_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:name, :avatar]},
      conflict_target: [:auth_id],
      returning: true
    )
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_user_settings(%User{} = user, attrs) do
    user
    |> User.change_settings(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias Mensaplan.Accounts.Group

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id) |> Repo.preload([:owner, :members])

  def get_group_by_server_id(server_id), do: Repo.get_by(Group, server_id: server_id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(%User{} = owner, attrs \\ %{}) do
    Ecto.Changeset.change(%Group{})
    |> Ecto.Changeset.put_assoc(:owner, owner)
    |> Ecto.Changeset.put_assoc(:members, [owner])
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  def remove_user_from_group!(%Group{} = group, user_id) do
    group = Repo.preload(group, [:owner, :members])
    new_members = Enum.filter(group.members, fn member -> member.id != user_id end)

    if group.owner_id == user_id do
      if not Enum.empty?(new_members) do
        new_owner = hd(new_members)
        Logger.info("Changing owner of group #{group.name} to #{new_owner.name}.")

        change_group(group)
        |> Ecto.Changeset.put_assoc(:owner, new_owner)
        |> Ecto.Changeset.put_assoc(:members, new_members)
        |> Repo.update!()
      else
        Logger.info("Deleting group #{group.name} because it has no members left.")
        Repo.delete!(group)
      end
    else
      change_group(group)
      |> Ecto.Changeset.put_assoc(:members, new_members)
      |> Repo.update!()
    end
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end
end
