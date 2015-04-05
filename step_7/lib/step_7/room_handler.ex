defmodule Step_7.RoomHandler do
  require EEx
  alias Step_7.RoomServer
  alias Step_7.UserServer

  def init(request, _options) do
    {:cowboy_rest, request, []}
  end

  def allowed_methods(request, state) do
    {["HEAD", "GET", "POST", "DELETE"], request, state}
  end

  def is_authorized(request, state) do
    room_name = :cowboy_req.binding(:name, request)

    new_state = if current_user_is_room_owner?(room_name, request) do
      Keyword.put(state, :current_user_is_owner, true)
    else
      Keyword.put(state, :current_user_is_owner, false)
    end

    case RoomServer.room_has_password?(room_name) do
      {true, {_, password}} ->
        case :cowboy_req.parse_header("authorization", request) do
          {:basic, _, ^password} -> {true, request, Keyword.put(new_state, :password, true)}
          _ -> {{false, "Basic realm='cowboy'"}, request, new_state}
        end
      _ ->
        {true, request, Keyword.put(new_state, :password, false)}
    end
  end

  def resource_exists(request, state) do
    room_name = :cowboy_req.binding(:name, request)
    case RoomServer.room_exists?(room_name) do
      true -> {true, request, Keyword.put(state, :room_info, {room_name, RoomServer.get_room(room_name)}) }
      false -> {false, request, state}
    end
  end

  def content_types_provided(request, state) do
    {[
        {{"text", "html", []}, :room_to_html},
        {{"application", "json", []}, :room_to_json}
      ], request, state}
  end

  def content_types_accepted(request, state) do
    {[
        {{"application", "json", []}, :room_from_json}
      ], request, state}
  end

  def delete_resource(request, state) do
    {room_name, _} = Keyword.get(state, :room_info)
    case RoomServer.delete_room(room_name) do
      :ok -> {true, request, room_name}
      _ -> {false, request, room_name}
    end
  end

  def room_to_html(request, state) do
    {room_name, room_data} = Keyword.get(state, :room_info)
    body = EEx.eval_file("templates/room.html.ex", assigns: [room_name: room_name, room_description: get_room_description(room_data), password_set: Keyword.get(state, :password), current_user: get_current_user_name(request), current_user_is_owner: Keyword.get(state, :current_user_is_owner)])
    {body, request, room_name}
  end

  defp get_room_description(room_data), do: room_data |> Keyword.get(:description)

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

  def room_to_json(request, {room_name, room_data}) do
    body = "{\"#{room_name}\": {\"connections\": #{inspect Keyword.get(room_data, :connections) }, \"description\": #{ inspect Keyword.get(room_data, :description) }}}\n"
    {body, request, room_name}
  end

  def room_from_json(request, state) do
    room_name = :cowboy_req.binding(:name, request)

    {:ok, [{update_data, true}], req2} = :cowboy_req.body_qs(request)

    case update_room(room_name, update_data) do
      :ok -> {true, request, state}
      _ -> {false, req2, state}
    end
  end

  defp update_room(room_name, update_data) do
    case Poison.Parser.parse!(update_data) do
      ["description", description] -> RoomServer.update_description(room_name, description)
      ["password", password] -> RoomServer.update_password(room_name, password)
    end    
  end

  defp current_user_is_room_owner?(room_name, request) do
    # 
    # What happens if someone tries to get a room that doesn't exist?
    # Since this function is called before the resource_exists function,
    # it will cause an error is a room that doesn't exists is sought

    RoomServer.get_room_owner(room_name) == get_current_user_name(request)
  end
end
