defmodule MensaplanWeb.PositionView do
  use MensaplanWeb, :live_view

  alias Mensaplan.Positions
  alias Mensaplan.Positions.Position

  @impl true
  def mount(_params, session, socket) do
    Phoenix.PubSub.subscribe(Mensaplan.PubSub, "positions")
    user = session["user"]
    socket = assign(socket, user: user)

    if user do
      pos = Positions.get_position_of_user(user) || %Position{}
      socket = assign(socket, form: to_form(Ecto.Changeset.change(pos)))

      positions = Positions.get_positions_visible_to_user(user)
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

  def handle_event("clear", _, socket) do
    Positions.expire_all_positions(socket.assigns.user)
    {:noreply, socket |> put_flash(:info, "Position cleared")}
  end

  def handle_event("save", %{"position" => user_params}, socket) do
    Positions.expire_all_positions(socket.assigns.user)

    m = Map.put(user_params, "owner_id", socket.assigns.user.id)

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
  def handle_info({:position_expired, id}, socket) do
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
