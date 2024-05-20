defmodule Mensaplan.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias Mensaplan.Repo

  alias Mensaplan.Accounts.User

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

  def get_user(auth_id), do: Repo.get_by(User, auth_id: auth_id)

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

  def list_groups_for_user(%User{} = user) do
    Repo.all(
      from g in Group,
        join: owner in assoc(g, :owner),
        where:
          g.owner_id == ^user.id or
            fragment(
              "exists(select * from group_members gm where gm.group_id = ? and gm.user_id = ?)",
              g.id,
              ^user.id
            ),
        select: %{id: g.id, name: g.name, avatar: g.avatar, owner_name: owner.name}
    )
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
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(owner, attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:owner, owner)
    |> Ecto.Changeset.put_assoc(:members, [owner])
    |> Repo.insert!()
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

  def remove_user_from_group(%User{} = user, %Group{} = group) do
    current_members = Repo.preload(group, :members).members
    new_members = Enum.filter(current_members, fn member -> member.id != user.id end)

    new_group =
      group
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:members, new_members)

    if group.owner == user do
      if not Enum.empty?(new_members) do
        Logger.info("Transferring ownership of group #{group.name} to #{hd(new_members).name}.")
        new_group |> Ecto.Changeset.put_assoc(:owner, hd(new_members)) |> Repo.update()
      else
        Logger.info("Deleting group #{group.name} because it has no members left.")
        Repo.delete!(group)
      end
    else
      Repo.update(new_group)
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
