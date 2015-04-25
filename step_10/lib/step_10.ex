defmodule Step_10 do
  use Application

  def start(_types, _args) do
    start_server(4000)
  end

  defp start_server(port) do
    Plug.Adapters.Cowboy.http Step_10.Router, [port: port]
  end
end
