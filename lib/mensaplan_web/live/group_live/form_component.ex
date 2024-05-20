defmodule MensaplanWeb.GroupLive.FormComponent do
  alias Mensaplan.Accounts
  use MensaplanWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="group-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:avatar]} type="text" label="URL to Avatar" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Group</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

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
    save_group(socket, socket.assigns.action, group_params)
  end

  defp save_group(socket, :edit, group_params) do
    case Accounts.update_group(socket.assigns.group, group_params) do
      {:ok, group} ->
        notify_parent({:saved, group})

        {:noreply,
         socket
         |> put_flash(:info, "Group updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_group(socket, :new, group_params) do
    case Accounts.create_group(socket.assigns.user, group_params) do
      {:ok, group} ->
        send_update(MensaplanWeb.GroupLive.List, {:saved, group})
        notify_parent({:saved, group})

        {:noreply,
         socket
         |> put_flash(:info, "Group created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
