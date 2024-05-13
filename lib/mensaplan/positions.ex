defmodule Mensaplan.Positions do
  @moduledoc """
  The Positions context.
  """

  import Ecto.Query, warn: false
  alias Mensaplan.Repo

  alias Mensaplan.Accounts.Group
  alias Mensaplan.Accounts.User
  alias Mensaplan.Positions.Position

  @doc """
  Returns the list of positions.

  ## Examples

      iex> list_positions()
      [%Position{}, ...]

  """
  def list_positions do
    Repo.all(Position)
  end

  @doc """
  Gets a single position.

  Raises `Ecto.NoResultsError` if the Position does not exist.

  ## Examples

      iex> get_position!(123)
      %Position{}

      iex> get_position!(456)
      ** (Ecto.NoResultsError)

  """
  def get_position!(id), do: Repo.get!(Position, id)

  def get_public_positions() do
    Repo.all(
      from p in Position,
        join: owner in assoc(p, :owner),
        where: p.public and not p.expired,
        select: %{id: p.id, name: "Login to see the name", avatar: owner.avatar, x: p.x, y: p.y}
    )
  end

  def get_position_of_user(%User{} = user) do
    Repo.one(
      from p in Position,
        where: p.owner_id == ^user.id and not p.expired,
        limit: 1,
        order_by: [desc: :inserted_at]
    )
  end

  @doc """
  Returns the list of positions a user is allowed to see:
  1. Public positions
  2. User's own position
  3. Positions of other users from common groups
  """
  def get_positions_visible_to_user(%User{} = user) do
    common_groups =
      from(g in Group,
        join: user_group in assoc(g, :members),
        where: user_group.id == ^user.id,
        select: g.id
      )

    Repo.all(
      from(p in Position,
        join: owner in assoc(p, :owner),
        join: owner_group in assoc(owner, :groups),
        where:
          not p.expired and
            (p.public or p.owner_id == ^user.id or owner_group.id in subquery(common_groups)),
        select: %{id: owner.id, name: owner.name, avatar: owner.avatar, x: p.x, y: p.y}
      )
    )
  end

  @doc """
  Creates a position.

  ## Examples

      iex> create_position(%{field: value})
      {:ok, %Position{}}

      iex> create_position(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_position(attrs \\ %{}) do
    %Position{owner_id: attrs["owner_id"]}
    |> Repo.preload(:owner)
    |> Position.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a position.

  ## Examples

      iex> delete_position(position)
      {:ok, %Position{}}

      iex> delete_position(position)
      {:error, %Ecto.Changeset{}}

  """
  def delete_position(%Position{} = position) do
    Repo.delete(position)
  end

  def expire_all_positions(user) do
    from(p in Position, where: not p.expired and p.owner_id == ^user.id)
    |> Repo.update_all(set: [expired: true])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking position changes.

  ## Examples

      iex> change_position(position)
      %Ecto.Changeset{data: %Position{}}

  """
  def change_position(%Position{} = position, attrs \\ %{}) do
    Position.changeset(position, attrs)
  end
end
