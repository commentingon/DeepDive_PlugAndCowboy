defmodule Step_12 do
  use Application

  def start(_types, _args) do
    case Step_12.RoomServer.start do
      {:ok, _} ->
        generate_default_chat_rooms
        start_server(4000)
      _ ->
        IO.puts "Unable to start Room Server"
        exit(:normal)
    end
  end

  defp start_server(port) do
    Plug.Adapters.Cowboy.http Step_12.Router, [port: port]

    IO.puts "Server listening on port #{port}"

    waiting_loop
  end

  defp waiting_loop do
    receive do
      _ -> waiting_loop
    end
  end

  defp generate_default_chat_rooms do
    for room <- ["General", "Tech", "Elixir", "Erlang"] do
      Step_12.RoomServer.create_room(room)
    end
  end
end
