defmodule MensaplanWeb.GroupLive.EditFormComponent do
  alias Mensaplan.Accounts
  use MensaplanWeb, :live_component

  @impl true
  def update(%{group: group} = assigns, socket) do
    changeset = Accounts.change_group(group)

    {:ok,
     socket
     |> assign(assigns)
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
         |> put_flash(:info, "Group updated successfully")
         |> push_patch(to: "/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end