defmodule MensaplanWeb.GroupController do
  use MensaplanWeb, :controller

  alias Mensaplan.Accounts
  alias Mensaplan.Accounts.Group

  action_fallback MensaplanWeb.FallbackController

  def create(conn, %{"group" => group_params}) do
    with {:ok, %Group{} = group} <- Accounts.create_group(group_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/groups/#{group}")
      |> render(:show, group: group)
    end
  end

  def show(conn, %{"id" => id}) do
    if group = Accounts.get_group_by_server_id(id) do
      render(conn, :show, group: group)
    else
      {:error, :not_found}
    end
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
