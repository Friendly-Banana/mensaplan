defmodule MensaplanWeb.GroupControllerTest do
  use MensaplanWeb.ConnCase

  import Mensaplan.AccountsFixtures

  alias Mensaplan.Accounts
  alias Mensaplan.Accounts.Group

  @create_attrs %{
    avatar: "some avatar",
    name: "some name",
    server_id: 123
  }
  @update_attrs %{
    avatar: "some updated avatar",
    name: "some updated name",
    server_id: 321
  }
  @invalid_attrs %{avatar: nil, name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json") |> authorize()}
  end

  test "get or create creates a group", %{conn: conn} do
    conn = post(conn, ~p"/api/groups", group: @create_attrs)

    resp = json_response(conn, 201)

    assert @create_attrs.server_id == resp["server_id"]
    assert 2 == resp["owner_id"]
  end

  test "get or create gets a group", %{conn: conn} do
    user = user_fixture()

    {:ok, group} =
      Mensaplan.Accounts.create_group(user, Map.put(@create_attrs, :owner_id, user.id))

    conn = post(conn, ~p"/api/groups", group: %{server_id: @create_attrs.server_id})

    resp = json_response(conn, 200)

    assert group.id == resp["id"]
    assert user.id == resp["owner_id"]
  end

  test "renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, ~p"/api/groups", group: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "join group", %{conn: conn} do
    user = user_fixture()
    group = group_fixture()

    conn = post(conn, ~p"/api/groups/join", %{"group_id" => group.id, "user_id" => user.id})

    json_response(conn, 201)

    assert Enum.member?(Accounts.get_group!(group.id).members, user)
  end

  describe "update group" do
    setup [:create_group]

    test "renders group when data is valid", %{conn: conn, group: %Group{id: id}} do
      conn = put(conn, ~p"/api/groups/#{id}", group: @update_attrs)
      resp = json_response(conn, 200)

      assert %{
               "id" => ^id,
               "avatar" => "some updated avatar",
               "name" => "some updated name"
             } = resp
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = put(conn, ~p"/api/groups/#{group}", group: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete group" do
    setup [:create_group]

    test "deletes chosen group", %{conn: conn, group: group} do
      conn = delete(conn, ~p"/api/groups/#{group.id}")
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_group!(group.id) end
    end
  end

  defp create_group(_) do
    group = group_fixture()
    %{group: group}
  end
end
