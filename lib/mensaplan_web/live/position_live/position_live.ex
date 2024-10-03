defmodule MensaplanWeb.PositionLive do
  require Logger
  use MensaplanWeb, :live_view

  alias Mensaplan.Accounts
  alias Mensaplan.Accounts.Group
  alias Mensaplan.Mensa
  alias Mensaplan.Positions
  alias Mensaplan.Positions.Position
  import MensaplanWeb.Components.Tooltip
  import MensaplanWeb.Gettext

  @impl true
  def mount(_params, session, socket) do
    # TODO Gettext.put_locale("de")
    Phoenix.PubSub.subscribe(Mensaplan.PubSub, "positions")
    user = session["user"]
    socket = assign(socket, user: user)

    Phoenix.PubSub.subscribe(Mensaplan.PubSub, "update_dishes")
    socket = assign_new(socket, :dishes, fn -> Mensa.list_todays_dishes(user) end)

    if user do
      Phoenix.PubSub.subscribe(Mensaplan.PubSub, "groups")
      pos = Positions.get_position_of_user(user) || %Position{}
      pos = Map.put(pos, :public, user.default_public)

      socket =
        assign(socket, form: to_form(Ecto.Changeset.change(pos)))
        |> stream(:groups, Mensaplan.Repo.preload(user, [:groups]).groups)

      {:ok, stream(socket, :positions, Positions.get_positions_visible_to_user(user))}
    else
      {:ok, stream(socket, :positions, Positions.get_public_positions())}
    end
  end

  @impl true
  def handle_event("position_validate", %{"position" => params}, socket) do
    form =
      Position.changeset(struct(Position, params), params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("position_clear", _, socket) do
    Positions.expire_all_positions(socket.assigns.user.id)
    socket = assign(socket, form: to_form(Ecto.Changeset.change(%Position{})))
    {:noreply, socket |> put_flash(:info, dgettext("messages", "Position cleared"))}
  end

  @impl true
  def handle_event("position_save", %{"position" => position_params}, socket) do
    Positions.expire_all_positions(socket.assigns.user.id)

    m = Map.put(position_params, "owner_id", socket.assigns.user.id)

    case Positions.create_position(m) do
      {:ok, position} ->
        Phoenix.PubSub.broadcast(Mensaplan.PubSub, "positions", {:position_saved, position})

        {:noreply,
         socket
         |> stream_insert(:positions, position_to_map(position))
         |> put_flash(:info, dgettext("messages", "Position set"))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("group_change_owner", %{"user_id" => user_id}, socket) do
    group = socket.assigns.group

    if group.owner_id == socket.assigns.user.id do
      {:ok, updated_group} = Accounts.update_group(group, %{owner_id: user_id})

      {:noreply,
       stream_insert(socket, :groups, updated_group)
       |> put_flash(:info, dgettext("messages", "Owner changed"))
       |> redirect(to: "/")}
    else
      {:noreply, put_flash(socket, :error, gettext("You are not the owner of this group"))}
    end
  end

  @impl true
  def handle_event("group_leave", %{"id" => id}, socket) do
    group = Accounts.get_group!(id)
    Accounts.remove_user_from_group!(group, socket.assigns.user.id)

    {:noreply, stream_delete(socket, :groups, group)}
  end

  @impl true
  def handle_event("group_kick", %{"user_id" => user_id}, socket) do
    group = socket.assigns.group

    if group.owner_id == socket.assigns.user.id do
      updated_group = Accounts.remove_user_from_group!(group, user_id)
      {:noreply, stream_insert(socket, :groups, updated_group)}
    else
      {:noreply, put_flash(socket, :error, gettext("You are not the owner of this group"))}
    end
  end

  @impl true
  def handle_event("group_delete", _, socket) do
    group = socket.assigns.group

    if group.owner_id == socket.assigns.user.id do
      {:ok, updated_group} = Accounts.delete_group(group)
      {:noreply, stream_delete(socket, :groups, updated_group)}
    else
      {:noreply, put_flash(socket, :error, gettext("You are not the owner of this group"))}
    end
  end

  @impl true
  def handle_event("dish_like", %{"id" => dish_id, "like" => like}, socket) do
    Mensa.like_dish(socket.assigns.user.id, dish_id, like)
    Phoenix.PubSub.broadcast(Mensaplan.PubSub, "update_dishes", {:update_dishes})
    {:noreply, socket}
  end

  @impl true
  def handle_event("dish_unlike", %{"id" => dish_id}, socket) do
    Mensa.unlike_dish(socket.assigns.user.id, dish_id)
    Phoenix.PubSub.broadcast(Mensaplan.PubSub, "update_dishes", {:update_dishes})
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    if socket.assigns.live_action do
      handle_action(socket.assigns.live_action, params, socket)
    else
      {:noreply, socket}
    end
  end

  defp handle_action(:group_new, _, socket) do
    {:noreply, socket |> assign(:group, %Group{})}
  end

  defp handle_action(:group_edit, %{"id" => id}, socket) do
    group = Accounts.get_group!(id)

    if group && group.owner_id == socket.assigns.user.id do
      {:noreply,
       socket
       |> assign(:page_title, gettext("Edit Group %{name}", name: group.name))
       |> assign(:group, group)}
    else
      {:noreply, socket |> put_flash(:error, dgettext("errors", "Group not found")) |> redirect(to: "/")}
    end
  end

  @impl true
  def handle_info({:update_dishes}, socket) do
    {:noreply, assign(socket, :dishes, Mensa.list_todays_dishes(socket.assigns.user))}
  end

  @impl true
  def handle_info({:group_saved, group}, socket) do
    {:noreply, stream_insert(socket, :groups, group)}
  end

  @impl true
  def handle_info({:group_deleted, id}, socket) do
    {:noreply, stream_delete_by_dom_id(socket, :groups, id)}
  end

  @impl true
  def handle_info({:position_saved, position}, socket) do
    if position.public or is_position_visible?(position, socket) do
      {:noreply, stream_insert(socket, :positions, position_to_map(position))}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:position_deleted, id}, socket) do
    {:noreply, stream_delete_by_dom_id(socket, :positions, id)}
  end

  defp is_position_visible?(position, socket) do
    position.owner_id == socket.assigns.user.id or
      Enum.any?(position.owner.groups, fn group ->
        Enum.member?(socket.assigns.user.groups, group)
      end)
  end

  defp position_to_map(%Position{} = position) do
    %{
      id: position.owner_id,
      name: position.owner.name,
      avatar: position.owner.avatar,
      x: position.x,
      y: position.y
    }
  end
end
