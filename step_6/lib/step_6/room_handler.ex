defmodule Step_6.RoomHandler do
  require EEx
  alias Step_6.RoomServer

  def init(request, _options) do
    {:cowboy_rest, request, []}
  end

  def allowed_methods(request, state) do
    {["HEAD", "GET", "POST", "DELETE"], request, state}
  end

  def is_authorized(request, state) do
    room_name = :cowboy_req.binding(:name, request)
    case RoomServer.room_has_password?(room_name) do
      {true, {_, password}} ->
        case :cowboy_req.parse_header("authorization", request) do
          {:basic, _, ^password} -> {true, request, Keyword.put(state, :password, true)}
          _ -> {{false, "Basic realm='cowboy'"}, request, state}
        end
      _ ->
        {true, request, Keyword.put(state, :password, false)}
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
    body = EEx.eval_file("templates/room.html.ex", assigns: [room_name: room_name, room_description: get_room_description(room_data), password_set: Keyword.get(state, :password)])
    {body, request, room_name}
  end

  defp get_room_description(room_data), do: room_data |> Keyword.get(:description)

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

  def update_room(room_name, update_data) do
    case Poison.Parser.parse!(update_data) do
      ["description", description] -> RoomServer.update_description(room_name, description)
      ["password", password] -> RoomServer.update_password(room_name, password)
    end    
  end
end
