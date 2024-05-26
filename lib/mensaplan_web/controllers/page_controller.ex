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
    if user = get_session(conn, :user) do
      conn
      |> assign(:user, user)
      |> render(:settings)
    else
      conn
      |> put_flash(:error, "Please login to access this page.")
      |> redirect(to: "/")
    end
  end

  def update_settings(conn, params = %{"default_public" => _}) do
    user = get_session(conn, :user)

    if user do
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
          |> put_flash(:error, "Failed to update settings")
          |> redirect(to: "/")
      end
    else
      conn
      |> put_status(:unauthorized)
      |> put_flash(:error, "Please login first.")
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
    case Accounts.accept_invite(get_session(conn, :user), uuid) do
      {:ok, _} ->
        put_flash(conn, :info, "You have joined the group") |> redirect(to: "/")

      {:error, reason} ->
        Logger.error("Invite invalid: #{reason}")
        put_flash(conn, :error, "No valid Invite") |> redirect(to: "/")
    end
  end
end
