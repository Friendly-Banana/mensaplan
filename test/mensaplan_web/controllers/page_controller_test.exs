defmodule MensaplanWeb.PageControllerTest do
  use MensaplanWeb.ConnCase

  test "GET / redirects", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 302) =~
             "<html><body>You are being <a href=\"/en\">redirected</a>.</body></html>"
  end

  test "GET /en", %{conn: conn} do
    conn = get(conn, ~p"/en")
    assert html_response(conn, 200) =~ "Mensaplan"
  end

  test "GET /nonexistent", %{conn: conn} do
    conn = get(conn, "/en/nonexistent")
    assert html_response(conn, 404) =~ "Not Found"
  end
end
