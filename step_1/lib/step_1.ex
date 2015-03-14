defmodule Step_1 do
  import Plug.Conn

  def init(options) do

  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello World")
  end

  def start_server(port \\ 4000) do
    {:ok, pid} = Plug.Adapters.Cowboy.http __MODULE__, [], port: port
    IO.puts "Server running on port: #{port}, with PID: #{inspect pid}"
  end
end
