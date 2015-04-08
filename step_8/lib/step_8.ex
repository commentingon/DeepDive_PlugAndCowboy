defmodule Step_8 do
  use Application

  def start(_types, _args) do
    case Step_8.RoomServer.start do
      {:ok, _} -> 
        generate_default_chat_rooms
        case Step_8.UserServer.start do
          {:ok, _} -> 
            generate_default_user
            start_server(4000)
          _ ->
            IO.puts "Unable to start the User Server"
            exit(:normal)
        end
      _ ->
        IO.puts "Unable to start the Room Server"
        exit(:normal)
    end
  end

  defp start_server(port) do
    :cowboy.start_http(:http, 100, [port: port], [env: [dispatch: dispatch_rules()]])

    IO.puts "Server listening on port #{port}"

    waiting_loop
  end

  defp dispatch_rules do
    :cowboy_router.compile(host_matches())
  end

  defp host_matches do
    [{:_, 
        path_matches()
      }]
  end

  defp path_matches do
    [
      {"/", Step_8.HomeHandler, [message: "Hello from a REST world!"]},
      {"/rooms", Step_8.RoomsHandler, []},
      {"/rooms/:name", Step_8.RoomHandler, []}, 
      {"/users", Step_8.UsersHandler, []},
      {"/users/:user_name", Step_8.UserHandler, []},
      {"/sessions", Step_8.SessionsHandler, []},
      {"/websocket/:channel", Step_8.WebsocketHandler, []},
      {"/js/[...]", :cowboy_static, {:priv_dir, :step_8, "/js"}},
      {"/css/[...]", :cowboy_static, {:priv_dir, :step_8, "/css"}}
    ]
  end

  defp waiting_loop do
    receive do
      _ -> waiting_loop
    end
  end

  defp generate_default_user do
    Step_8.UserServer.create_user("admin", "foobar")
  end

  defp generate_default_chat_rooms do
    for room <- ["General", "Tech", "Elixir", "Erlang"] do
      Step_8.RoomServer.create_room(room)
      Step_8.RoomServer.update_owners_name(room, "admin")
    end
  end
end
