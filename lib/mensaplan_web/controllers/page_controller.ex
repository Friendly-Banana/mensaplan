defmodule MensaplanWeb.PageController do
  use MensaplanWeb, :controller

  require Logger
  alias Mensaplan.Accounts
  alias Mensaplan.Repo
  alias Mensaplan.Accounts.User

  def about(conn, _params) do
    render(conn, :about)
  end

  def settings(conn, _params) do
    render(conn, :settings)
  end

  def update_settings(conn, params = %{"default_public" => _}) do
    user = get_session(conn, :user)

    case User.change_settings(user, params)
         |> Repo.update() do
      {:ok, updated_user} ->
        put_session(conn, :user, updated_user)
        |> put_flash(:info, "Settings updated.")
        |> redirect(to: "/settings")

      {:error, reason} ->
        Logger.error("Failed to update settings: #{inspect(reason)}")

        conn
        |> put_status(:bad_request)
        |> put_flash(:error, "Failed to update settings.")
        |> redirect(to: "/")
    end
  end

  def join(conn, %{"invite" => uuid}) do
    case Accounts.fetch_invite(uuid) do
      nil ->
        conn
        |> put_flash(:error, "Invalid invitation link. Please ask for a new one.")
        |> redirect(to: "/")

      invite ->
        conn
        |> assign(:invite, invite)
        |> render(:join)
    end
  end

  def join_confirm(conn, %{"invite" => uuid}) do
    case Accounts.accept_invite(conn.assigns[:user], uuid) do
      {:ok, _} ->
        put_flash(conn, :info, "You have joined the group.") |> redirect(to: "/")

      {:error, reason} ->
        Logger.error("Invite invalid: #{reason}")

        put_flash(conn, :error, "Invalid invitation link. Please ask for a new one.")
        |> redirect(to: "/")
    end
  end
end
