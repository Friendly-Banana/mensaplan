defmodule MensaplanWeb.PositionView do
  use MensaplanWeb, :live_view

  alias Mensaplan.Positions
  alias Mensaplan.Positions.Position

  @impl true
  def mount(_params, session, socket) do
    user = session["user"]
    socket = assign(socket, user: user)

    if user do
      pos = Positions.get_position_of_user(user) || %Position{}
      socket = assign(socket, form: to_form(Ecto.Changeset.change(pos)))

      positions = Positions.get_positions_visible_to_user(user)
      IO.inspect(positions)
      {:ok, stream(socket, :positions, positions)}
    else
      socket = assign(socket, form: to_form(Ecto.Changeset.change(%Position{})))

      {:ok, stream(socket, :positions, Positions.get_public_positions())}
    end
  end

  @impl true
  def handle_event("validate", %{"position" => params}, socket) do
    form =
      Position.changeset(struct(Position, params), params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"position" => user_params}, socket) do
    Positions.expire_all_positions(socket.assigns.user)

    m = Map.put(user_params, "owner_id", socket.assigns.user.id)

    case Positions.create_position(m) do
      {:ok, position} ->
        {:noreply,
         socket
         |> stream(:positions, [position])
         |> put_flash(:info, "Position set")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
