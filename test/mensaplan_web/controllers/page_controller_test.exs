defmodule MensaplanWeb.PageControllerTest do
  use MensaplanWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Mensaplan"
  end

  test "GET /nonexistent", %{conn: conn} do
    conn = get(conn, "/nonexistent")
    assert html_response(conn, 404) =~ "Not Found"
  end
end
