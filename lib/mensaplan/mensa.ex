defmodule Mensaplan.Mensa do
  @moduledoc """
  The Mensa context.
  """

  import Ecto.Query, warn: false
  import TimeUtils

  alias Mensaplan.Repo
  alias Mensaplan.Mensa.Dish
  alias Mensaplan.Mensa.Like

  @doc """
  Returns the list of dishes.

  ## Examples

      iex> list_dishes()
      [%Dish{}, ...]

  """
  def list_dishes do
    Repo.all(Dish)
  end

  def list_todays_dishes(user \\ nil) do
    query =
      from d in Dish,
        where: d.date == ^local_now(),
        left_join: l in assoc(d, :likes),
        group_by: [d.id],
        order_by: [d.category, d.name, d.id],
        select: %{
          id: d.id,
          name: d.name,
          price: d.price,
          category: d.category,
          likes: coalesce(sum(l.like), 0)
        }

    query =
      if user do
        from d in query,
          left_join: l in assoc(d, :likes),
          on: l.user_id == ^user.id,
          select_merge: %{user_likes: coalesce(sum(l.like), 0)}
      else
        query
      end

    Repo.all(query)
  end

  @doc """
  Gets a single dish.

  Raises `Ecto.NoResultsError` if the Dish does not exist.

  ## Examples

      iex> get_dish!(123)
      %Dish{}

      iex> get_dish!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dish!(id), do: Repo.get!(Dish, id)
  def get_dish_by_name(name), do: Repo.get_by(Dish, name: name)

  @doc """
  Creates a dish.

  ## Examples

      iex> create_dish(%{field: value})
      {:ok, %Dish{}}

      iex> create_dish(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dish(attrs \\ %{}) do
    %Dish{}
    |> Dish.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dish.

  ## Examples

      iex> update_dish(dish, %{field: new_value})
      {:ok, %Dish{}}

      iex> update_dish(dish, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dish(%Dish{} = dish, attrs) do
    dish
    |> Dish.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dish.

  ## Examples

      iex> delete_dish(dish)
      {:ok, %Dish{}}

      iex> delete_dish(dish)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dish(%Dish{} = dish) do
    Repo.delete(dish)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dish changes.

  ## Examples

      iex> change_dish(dish)
      %Ecto.Changeset{data: %Dish{}}

  """
  def change_dish(%Dish{} = dish, attrs \\ %{}) do
    Dish.changeset(dish, attrs)
  end

  @doc """
  Likes a dish. Use false to dislike a dish.
  """
  def like_dish(user_id, dish_id, like \\ true) do
    value = if(like, do: 1, else: -1)

    Repo.insert!(%Like{user_id: user_id, dish_id: dish_id, like: value},
      on_conflict: [set: [like: value]],
      conflict_target: [:dish_id, :user_id],
      returning: false
    )
  end

  @doc """
  Removes all votes on a dish.
  """
  def unlike_dish(user_id, dish_id) do
    Repo.delete_all(from l in Like, where: l.user_id == ^user_id and l.dish_id == ^dish_id)
  end
end
