defmodule MensaplanWeb.PageController do
  use MensaplanWeb, :controller

  require Logger
  alias Mensaplan.Accounts

  def about(conn, _params) do
    render(conn, :about,
      page_title: gettext("About"),
      page_description: gettext("Learn more about Mensaplan, the helper for the TUM Mensa.")
    )
  end

  def settings(conn, _params) do
    render(conn, :settings, page_title: gettext("Settings"))
  end

  def update_settings(conn, params = %{"default_public" => _}) do
    user = get_session(conn, :user)

    case Accounts.update_user_settings(user, params) do
      {:ok, updated_user} ->
        put_session(conn, :user, updated_user)
        |> put_flash(:info, dgettext("messages", "Settings updated."))
        |> redirect(to: "/settings")

      {:error, reason} ->
        Logger.error("Failed to update settings: #{inspect(reason)}")

        conn
        |> put_status(:bad_request)
        |> put_flash(:error, dgettext("errors", "Failed to update settings."))
        |> redirect(to: "/settings")
    end
  end

  def join(conn, %{"invite" => uuid}) do
    case Accounts.fetch_invite(uuid) do
      nil ->
        conn
        |> put_flash(
          :error,
          dgettext("errors", "Invalid invitation link. Please ask for a new one.")
        )
        |> redirect(to: "/")

      invite ->
        conn
        |> assign(:page_title, "Join Group " <> invite.group.name)
        |> assign(:invite, invite)
        |> render(:join)
    end
  end

  def join_confirm(conn, %{"invite" => uuid}) do
    case Accounts.accept_invite(conn.assigns[:user], uuid) do
      {:ok, _} ->
        put_flash(conn, :info, dgettext("messages", "You have joined the group."))
        |> redirect(to: "/")

      {:error, reason} ->
        Logger.error("Invite invalid: #{reason}")

        put_flash(
          conn,
          :error,
          dgettext("errors", "Invalid invitation link. Please ask for a new one.")
        )
        |> redirect(to: "/")
    end
  end
end
