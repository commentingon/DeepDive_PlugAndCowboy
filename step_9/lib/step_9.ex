defmodule Step_9 do
  use Application

  def start(_types, _args) do
    start_server(4000)
  end

  defp start_server(port) do
    # Plug.Adapters.Cowboy.http Step_9.Handler, [port: port]
    # Plug.Adapters.Cowboy.http Step_9.AltHandler, [port: port]
    Plug.Adapters.Cowboy.http Step_9.Router, [port: port]
  end
end
