defmodule Step_8.WebsocketHandler do
  alias Step_8.RoomServer

  def init(request, options) do
    room = :cowboy_req.binding(:channel, request)

    case RoomServer.enter_room(room, self()) do
      :ok -> {:cowboy_websocket, request, [room: room]}
      _ -> {false, request, []}
    end 
  end

  def websocket_handle({:text, msg}, request, [room: room] = state) do
    IO.puts "#{room} said: #{inspect msg}" 
    case RoomServer.distribute_msg(room, msg) do
      :ok -> {:ok, request, state}
      _ -> {false, request, state}
    end
  end

  def websocket_info({:send_msg, msg}, request, state) do
    {:reply, [text: msg], request, state}
  end
end
