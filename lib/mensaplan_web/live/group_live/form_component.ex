defmodule MensaplanWeb.GroupLive.FormComponent do
  alias Mensaplan.Accounts
  use MensaplanWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= gettext("New Group") %>
      </.header>

      <.simple_form
        for={@form}
        id="group-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label={gettext("Name")} />
        <.input field={@form[:avatar]} type="text" label={gettext("URL to Group Avatar")} />
        <:actions>
          <.button phx-disable-with={gettext("Creating...")}><%= gettext("Create Group") %></.button>
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
    case Accounts.create_group(socket.assigns.user, group_params) do
      {:ok, group} ->
        Phoenix.PubSub.broadcast(Mensaplan.PubSub, "groups", {:group_saved, group})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("messages", "Group created successfully"))
         |> push_patch(to: "/" <> Gettext.get_locale(MensaplanWeb.Gettext))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
