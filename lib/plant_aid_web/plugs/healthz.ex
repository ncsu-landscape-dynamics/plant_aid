defmodule PlantAidWeb.Plugs.Healthz do
  @moduledoc """
  Answers `GET /healthz` with `200 ok` for Kubernetes readiness/liveness probes.

  Sits in the endpoint before logging, sessions and the router, so probes are
  cheap and don't fill the logs. It deliberately does not touch the database:
  a database blip should not make Kubernetes restart every pod.
  """
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{method: method, request_path: "/healthz"} = conn, _opts)
      when method in ["GET", "HEAD"] do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "ok")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
