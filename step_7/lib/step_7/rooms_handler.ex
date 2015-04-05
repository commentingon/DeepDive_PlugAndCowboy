defmodule Step_7.RoomsHandler do
  require EEx
  alias Step_7.RoomServer
  alias Step_7.UserServer

  def init(request, options) do
    {:cowboy_rest, request, options}
  end

  def allowed_methods(request, state) do
    {["GET", "POST"], request, state}
  end

  def content_types_provided(request, state) do
    {[
        {{"text", "html", []}, :rooms_to_html}
      ], request, state}
  end

  def content_types_accepted(request, state) do
    {[
        {{"application", "x-www-form-urlencoded", []}, :room_from_html},
        {{"application", "json", []}, :room_from_json}
      ], request, state}
  end

  def rooms_to_html(request, state) do
    body = EEx.eval_file("templates/rooms.html.ex", assigns: [rooms: get_all_rooms(), current_user: get_current_user_name(request)])

    {body, request, state}
  end

  defp get_all_rooms do
    # ["here", "there", "this", "that"]
    RoomServer.get_all_rooms
  end

  defp get_current_user_name(request) do
    case :cowboy_req.match_cookies([{:sessionid, [], nil}], request) do
      %{sessionid: sessionid} when not is_nil(sessionid) ->
        case UserServer.get_user_by_hash(sessionid) do
          [username: username, password_hash: _] -> username
          _ -> nil
        end
      _ -> nil
    end 
  end

  def room_from_html(request, state) do
    {:ok, [{_param, room_name}], req2} = :cowboy_req.body_qs(request)
    
    # IO.puts "Bindings: #{inspect room_name}"

    case RoomServer.create_room(room_name) do
      :ok -> 
        RoomServer.update_owners_name(room_name, get_current_user_name(request))
        {{true, "/rooms"}, req2, state}
      _ -> {false, req2, state}
    end
  end

  def room_from_json(request, state) do
    {:ok, [{room_name, true}], req2} = :cowboy_req.body_qs(request)

    # IO.puts "Bindings: #{inspect room_name}"

    case RoomServer.create_room(room_name) do
      :ok -> 
        RoomServer.update_owners_name(room_name, get_current_user_name(request))
        {true, req2, state}
      _ -> {false, req2, state}
    end
  end
end
