defmodule MensaplanWeb.UserControllerTest do
  use MensaplanWeb.ConnCase

  @create_attrs %{
    auth_id: "some auth_id",
    avatar: "some avatar",
    default_public: true,
    name: "some name"
  }
  @invalid_attrs %{auth_id: nil, avatar: nil, default_public: nil, name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json") |> authorize()}
  end

  test "get or create creates a user", %{conn: conn} do
    conn = post(conn, ~p"/api/users/auth/#{@create_attrs.auth_id}", user: @create_attrs)

    resp = json_response(conn, 200)

    assert @create_attrs.auth_id == resp["auth_id"]
    assert @create_attrs.avatar == resp["avatar"]
  end

  test "get or create gets a user", %{conn: conn} do
    {:ok, user} = Mensaplan.Accounts.create_user(@create_attrs)

    conn = post(conn, ~p"/api/users/auth/#{user.auth_id}", user: @create_attrs)

    resp = json_response(conn, 200)

    assert user.id == resp["id"]
  end

  test "renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, ~p"/api/users/auth/99999", user: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end
end
