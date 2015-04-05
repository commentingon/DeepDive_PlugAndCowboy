defmodule Step_7 do
  use Application

  def start(_types, _args) do
    case Step_7.RoomServer.start do
      {:ok, _} -> 
        generate_default_chat_rooms
        case Step_7.UserServer.start do
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
      {"/", Step_7.HomeHandler, [message: "Hello from a REST world!"]},
      {"/rooms", Step_7.RoomsHandler, []},
      {"/rooms/:name", Step_7.RoomHandler, []}, 
      {"/users", Step_7.UsersHandler, []},
      {"/users/:user_name", Step_7.UserHandler, []},
      {"/sessions", Step_7.SessionsHandler, []},
      {"/js/[...]", :cowboy_static, {:priv_dir, :step_7, "/js"}},
      {"/css/[...]", :cowboy_static, {:priv_dir, :step_7, "/css"}}
    ]
  end

  defp waiting_loop do
    receive do
      _ -> waiting_loop
    end
  end

  defp generate_default_user do
    Step_7.UserServer.create_user("admin", "foobar")
  end

  defp generate_default_chat_rooms do
    for room <- ["General", "Tech", "Elixir", "Erlang"] do
      Step_7.RoomServer.create_room(room)
      Step_7.RoomServer.update_owners_name(room, "admin")
    end
  end
end
