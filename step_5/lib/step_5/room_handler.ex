defmodule Step_5.RoomHandler do
  require EEx
  alias Step_5.RoomServer

  def init(request, options) do
    {:cowboy_rest, request, options}
  end

  def allowed_methods(request, state) do
    {["HEAD", "GET", "POST", "DELETE"], request, state}
  end

  def resource_exists(request, _state) do
    room_name = :cowboy_req.binding(:name, request)
    case RoomServer.room_exists?(room_name) do
      true -> {true, request, {room_name, RoomServer.get_room(room_name)} }
      false -> {false, request, room_name}
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

  def delete_resource(request, {room_name, _}) do
    case RoomServer.delete_room(room_name) do
      :ok -> {true, request, room_name}
      _ -> {false, request, room_name}
    end
  end

  def room_to_html(request, {room_name, room_data}) do
    body = EEx.eval_file("templates/room.html.ex", assigns: [room_name: room_name, room_description: get_room_desciption(room_data)])
    {body, request, room_name}
  end

  defp get_room_desciption(room_data), do: room_data |> Keyword.get(:description)

  def room_to_json(request, {room_name, room_data}) do
    body = "{\"#{room_name}\": {\"connections\": #{inspect Keyword.get(room_data, :connections) }, \"description\": #{ inspect Keyword.get(room_data, :description) }}}\n"
    {body, request, room_name}
  end

  def room_from_json(request, state) do
    room_name = :cowboy_req.binding(:name, request)

    {:ok, [{room_description, true}], req2} = :cowboy_req.body_qs(request)

    case RoomServer.update_description(room_name, room_description) do
      :ok -> {true, request, state}
      _ -> {false, req2, state}
    end
  end
end
