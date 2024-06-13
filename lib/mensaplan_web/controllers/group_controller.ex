defmodule MensaplanWeb.GroupController do
  use MensaplanWeb, :controller

  alias Mensaplan.Accounts
  alias Mensaplan.Accounts.Group

  action_fallback MensaplanWeb.FallbackController

  def get_or_create(conn, %{"group" => group_params}) do
    group_params = Map.new(group_params, fn {k, v} -> {String.to_existing_atom(k), v} end)

    case Accounts.get_group_by_server_id(group_params.server_id) do
      nil ->
        case Accounts.create_group(conn.assigns.user, group_params) do
          {:ok, %Group{} = group} ->
            conn
            |> put_status(:created)
            |> render(:show, group: group)
        end

      group ->
        render(conn, :show, group: group)
    end
  end

  def join_group(conn, %{"group_id" => group_id, "user_id" => user_id}) do
    user = Accounts.get_user!(user_id)
    group = Accounts.get_group!(group_id)
    group = Accounts.add_user_to_group(user, group)

    conn
    |> put_status(:created)
    |> render(:show, group: group)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Accounts.get_group!(id)

    with {:ok, %Group{} = group} <- Accounts.update_group(group, group_params) do
      render(conn, :show, group: group)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Accounts.get_group!(id)

    with {:ok, %Group{}} <- Accounts.delete_group(group) do
      send_resp(conn, :no_content, "")
    end
  end
end
