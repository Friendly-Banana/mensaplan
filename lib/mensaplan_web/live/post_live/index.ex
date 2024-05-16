defmodule MensaplanWeb.GroupLive.Index do
  use MensaplanWeb, :live_component

  alias Mensaplan.Accounts
  alias Mensaplan.Accounts.Group

  @impl true
  def update(assigns, socket) do
    {:ok, stream(socket, :groups, Accounts.list_groups_for_user(assigns.user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Group")
    |> assign(:group, Accounts.get_group!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Group")
    |> assign(:group, %Group{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Your Groups")
    |> assign(:group, nil)
  end

  @impl true
  def handle_info({MensaplanWeb.GroupLive.FormComponent, {:saved, group}}, socket) do
    {:noreply, stream_insert(socket, :groups, group)}
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
