defmodule Step_9.AltHandler do
  import Plug.Conn
  alias Plug.Conn

  require EEx

  def init(options) do
    options
  end

  def call(conn = %Conn{path_info: []}, _opts) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(status_code(), body([message: "Hello from a Template"]))
  end

  def call(conn = %Conn{path_info: [message]}, _opts) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(status_code(), body([message: message |> split_underscores_and_join]))
  end

  defp status_code, do: 200

  defp body(params) do
    EEx.eval_file("templates/index.html.ex", assigns: params)
  end

  defp split_underscores_and_join(string) do
    string
    |> String.split("_")
    |> Enum.join(" ")
    |> String.capitalize
  end
end
