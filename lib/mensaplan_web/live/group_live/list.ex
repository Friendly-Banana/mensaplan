defmodule MensaplanWeb.GroupLive.List do
  alias Mensaplan.Accounts.Group
  use MensaplanWeb, :live_component

  alias Mensaplan.Accounts

  @impl true
  def update(assigns, socket) do
    {:ok,
     stream(
       socket,
       :groups,
       Accounts.list_groups_for_user(assigns.user)
     )
     |> assign(:live_action, :none)
     |> assign(:user, assigns.user)}
  end

  def handle_info({:saved, group}, socket) do
    # todo handle form message
    IO.puts("Group saved1")
    {:noreply, stream_insert(socket, :groups, group)}
  end

  @impl true
  def handle_event("new", _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "New Group")
     |> assign(:group, %Group{})
     |> stream_insert(:groups, %Group{id: -1, name: "New Group", owner_id: 1})
     |> assign(:live_action, :new)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    socket
    |> assign(:page_title, "Edit Group")
    |> assign(:group, Accounts.get_group!(id))
    |> assign(:live_action, :edit)
  end

  @impl true
  def handle_event("leave", %{"id" => id}, socket) do
    group = Accounts.get_group!(id)
    {:ok, _} = Accounts.remove_user_from_group(socket.assigns.user, group)

    {:noreply, stream_delete(socket, :groups, group)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    group = Accounts.get_group!(id)
    {:ok, _} = Accounts.delete_group(group)

    {:noreply, stream_delete(socket, :groups, group)}
  end
end
