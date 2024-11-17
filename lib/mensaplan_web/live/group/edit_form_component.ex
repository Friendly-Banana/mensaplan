defmodule MensaplanWeb.GroupLive.EditFormComponent do
  use MensaplanWeb, :live_component

  alias Mensaplan.Accounts
  import MensaplanWeb.Components.Tooltip

  @impl true
  def update(%{group: group} = assigns, socket) do
    changeset = Accounts.change_group(group)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:invite, nil)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"group" => group_params}, socket) do
    changeset =
      socket.assigns.group
      |> Accounts.change_group(group_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"group" => group_params}, socket) do
    group_params = Map.put(group_params, "owner_id", socket.assigns.user.id)

    case Accounts.update_group(socket.assigns.group, group_params) do
      {:ok, group} ->
        Phoenix.PubSub.broadcast(Mensaplan.PubSub, "groups", {:group_saved, group})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("messages", "Group updated successfully"))
         |> push_patch(to: "/" <> Gettext.get_locale(MensaplanWeb.Gettext))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("invite", _, socket) do
    group = socket.assigns.group

    if group.owner_id == socket.assigns.user.id do
      {:ok, invite} = Accounts.create_invite(socket.assigns.user, group)

      {:noreply,
       assign(socket, :invite, MensaplanWeb.Endpoint.url() <> ~p"/join/" <> invite.uuid)}
    else
      {:noreply, put_flash(socket, :error, gettext("You are not the owner of this group"))}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
