defmodule PlantAidWeb.Plugs.HealthzTest do
  use PlantAidWeb.ConnCase, async: true

  test "GET /healthz returns 200 ok", %{conn: conn} do
    conn = get(conn, "/healthz")
    assert response(conn, 200) == "ok"
  end
end
