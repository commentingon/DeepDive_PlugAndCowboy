defmodule Step_13 do
  use Application

  def start(_types, _args) do
    case Step_13.RoomServer.start do
      {:ok, _} ->
        generate_default_chat_rooms
        case Step_13.UserServer.start do
          {:ok, _} ->
            generate_default_user
            start_server(4000)
          _ ->
            IO.puts "Unable to start to User Server"
            exit(:normal)
        end
      _ ->
        IO.puts "Unable to start Room Server"
        exit(:normal)
    end
  end

  defp start_server(port) do
    Plug.Adapters.Cowboy.http Step_13.Router, [port: port]

    IO.puts "Server listening on port #{port}"

    waiting_loop
  end

  defp waiting_loop do
    receive do
      _ -> waiting_loop
    end
  end

  defp generate_default_user do
    Step_13.UserServer.create_user("admin", "foobar")
  end

  defp generate_default_chat_rooms do
    for room <- ["General", "Tech", "Elixir", "Erlang"] do
      Step_13.RoomServer.create_room(room)
      Step_13.RoomServer.update_owners_name(room, "admin")
    end
  end
end
