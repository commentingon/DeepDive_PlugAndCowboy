defmodule Step_6 do
  use Application

  def start(_types, _args) do
    case Step_6.RoomServer.start do
      {:ok, _} -> 
        generate_default_chat_rooms
        start_server(4000)
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
      {"/", Step_6.HomeHandler, [message: "Hello from a REST world!"]},
      {"/rooms", Step_6.RoomsHandler, []},
      {"/rooms/:name", Step_6.RoomHandler, []}, 
      {"/js/[...]", :cowboy_static, {:priv_dir, :step_6, "/js"}},
      {"/css/[...]", :cowboy_static, {:priv_dir, :step_6, "/css"}}
    ]
  end

  defp waiting_loop do
    receive do
      _ -> waiting_loop
    end
  end

  defp generate_default_chat_rooms do
    for room <- ["General", "Tech", "Elixir", "Erlang"] do
      Step_6.RoomServer.create_room(room)
    end
  end
end
