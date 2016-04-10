defmodule JsonApi do
  def init(opts), do: opts

  def call(conn, opts) do
    jsonify(conn, opts, opts[:on] || "api")
  end

  def jsonify(%Plug.Conn{path_info: [on | _path]} = conn, _opts, on) do
    conn |>
    Plug.Conn.put_resp_header("content-type", "application/json")
  end
  def jsonify(conn, _opts, _on), do: conn

end
