defmodule MensaplanWeb.PageController do
  use MensaplanWeb, :controller

  alias Mensaplan.UserData
  alias Mensaplan.Repo
  alias Mensaplan.UserData.Position
  import Phoenix.Component, only: [to_form: 1, assign: 2]

  def home(conn, _params) do
    conn = assign(conn, :positions, Repo.all(Position))
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(UserData.create_position(%Position{})))}
  end

  def handle_event("validate", %{"position" => params}, socket) do
    form =
      UserData.create_position(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"position" => user_params}, socket) do
    case UserData.create_position(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "position created")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def about(conn, _params) do
    render(conn, :about)
  end
end
