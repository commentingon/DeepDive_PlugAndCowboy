defmodule Step_10.Handler do
  import Plug.Conn
  alias Plug.Conn
  require EEx

  def init(options) do
    options
  end

  def call(conn = %Conn{path_info: []}, _options) do
    conn |> build_reply
  end

  def call(conn, _options) do
    conn
  end

  def build_reply(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(status_code(), body([message: "Hello from a Stylish Template"]))
  end

  defp status_code, do: 200
  
  defp body(params) do
    EEx.eval_file("templates/index.html.ex", assigns: params)
  end
end
