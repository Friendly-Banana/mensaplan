defmodule MensaplanWeb.PageView do
  use MensaplanWeb, :live_view

  alias Mensaplan.UserData
  alias Mensaplan.UserData.Position
  import Phoenix.Component

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} phx-change="validate" phx-submit="save">
      <.input field={@form[:x]} label="X" />
      <.input field={@form[:y]} label="Y" />
      <:actions>
        <.button>Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    p = UserData.change_position(%Position{user: "a sfsd", x: 0.0, y: 0.0})
    {:ok, assign(socket, form: to_form(p))}
  end

  @impl true
  def handle_event("validate", %{"position" => params}, socket) do
    u = UserData.change_position(params)

    form = u
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"position" => user_params}, socket) do
    case UserData.create_position(user_params) do
      {:ok, _position} ->
        {:noreply,
         socket
         |> put_flash(:info, "Position set")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
