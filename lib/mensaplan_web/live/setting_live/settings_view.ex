defmodule MensaplanWeb.SettingsView do
  use MensaplanWeb, :live_view

  alias Mensaplan.Accounts

  @impl true
  def mount(_params, session, socket) do
    if user = session["user"] do
      {:ok, assign(socket, user: user, form: to_form(Ecto.Changeset.change(user)))}
    else
      {:ok,
       socket
       |> put_flash(:error, "You need to be logged in to access this page.")
       |> redirect(to: "/")}
    end
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    form =
      Accounts.change_user(socket.assigns.user, user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, _user} ->
        {:noreply, redirect(socket, to: "/update_user_in_session")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
