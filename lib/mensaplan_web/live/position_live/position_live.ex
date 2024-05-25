defmodule MensaplanWeb.PositionLive do
  require Logger
  alias Mensaplan.Accounts.Group
  use MensaplanWeb, :live_view

  alias Mensaplan.Accounts
  alias Mensaplan.Positions
  alias Mensaplan.Positions.Position

  @impl true
  def mount(_params, session, socket) do
    Phoenix.PubSub.subscribe(Mensaplan.PubSub, "positions")
    user = session["user"]
    socket = assign(socket, user: user)

    if user do
      Phoenix.PubSub.subscribe(Mensaplan.PubSub, "groups")
      pos = Positions.get_position_of_user(user) || %Position{}
      pos = Map.put(pos, :public, user.default_public)

      socket =
        assign(socket, form: to_form(Ecto.Changeset.change(pos)))
        |> stream(:groups, Accounts.list_groups_for_user(user))

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
    Positions.expire_all_positions(socket.assigns.user)
    {:noreply, socket |> put_flash(:info, "Position cleared")}
  end

  @impl true
  def handle_event("position_save", %{"position" => position_params}, socket) do
    Positions.expire_all_positions(socket.assigns.user)

    m = Map.put(position_params, "owner_id", socket.assigns.user.id)

    case Positions.create_position(m) do
      {:ok, position} ->
        Phoenix.PubSub.broadcast(Mensaplan.PubSub, "positions", {:position_saved, position})

        {:noreply,
         socket
         |> stream_insert(:positions, position_to_map(position))
         |> put_flash(:info, "Position set")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("group_toggle", %{"id" => id}, socket) do
    IO.puts("Toggling group #{id}")
    # TODO
    {:noreply, socket}
  end

  @impl true
  def handle_event("group_transfer_owner", %{"user_id" => user_id}, socket) do
    group = socket.assigns.group

    if group.owner_id == socket.assigns.user.id do
      {:ok, updated_group} = Accounts.update_group(group, %{owner_id: user_id})
      {:noreply, stream_insert(socket, :groups, updated_group)}
    else
      {:noreply, put_flash(socket, :error, "You are not the owner of this group")}
    end
  end

  @impl true
  def handle_event("group_leave", %{"id" => id}, socket) do
    group = Accounts.get_group!(id)
    Accounts.remove_user_from_group(socket.assigns.user.id, group)

    {:noreply, stream_delete(socket, :groups, group)}
  end

  @impl true
  def handle_event("group_kick", %{"user_id" => user_id}, socket) do
    group = socket.assigns.group

    if group.owner_id == socket.assigns.user.id do
      updated_group = Accounts.remove_user_from_group(user_id, group)
      {:noreply, stream_insert(socket, :groups, updated_group)}
    else
      {:noreply, put_flash(socket, :error, "You are not the owner of this group")}
    end
  end

  @impl true
  def handle_event("group_delete", _, socket) do
    group = socket.assigns.group

    if group.owner_id == socket.assigns.user.id do
      {:ok, _} = Accounts.delete_group(group)
      {:noreply, stream_delete(socket, :groups, group)}
    else
      {:noreply, put_flash(socket, :error, "You are not the owner of this group")}
    end
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
    {:noreply,
     socket
     |> assign(:group, %Group{})}
  end

  defp handle_action(:group_edit, %{"id" => id}, socket) do
    group = Accounts.get_loaded_group(id)

    if group && group.owner_id == socket.assigns.user.id do
      {:noreply,
       socket
       |> assign(:page_title, "Edit Group")
       |> assign(:group, group)}
    else
      {:noreply, socket |> put_flash(:error, "Group not found") |> redirect(to: "/")}
    end
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
    if position.public or
         (socket.assigns.user &&
            (position.owner_id == socket.assigns.user.id or
               Enum.any?(position.owner.groups, fn group ->
                 Enum.member?(socket.assigns.user.groups, group)
               end))) do
      {:noreply, stream_insert(socket, :positions, position_to_map(position))}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:position_deleted, id}, socket) do
    {:noreply, stream_delete_by_dom_id(socket, :positions, id)}
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
