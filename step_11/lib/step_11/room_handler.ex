defmodule Step_11.RoomHandler do
  use Plug.Router
  require EEx
  alias Step_11.RoomServer

  plug :match
  plug :dispatch

  get "/rooms/:name" do
    if  RoomServer.room_exists?(name) do 
      room_data = RoomServer.get_room(name)
      case Plug.Conn.get_req_header(conn, "content-type") do
        [] ->
          room_to_html(conn, name, room_data)
        ["text/html"] ->
          room_to_html(conn, name, room_data) 
        ["application/json"] ->
          room_to_json(conn, name, room_data)
      end
    else
      Plug.Conn.send_resp(conn, 500, "")
    end
  end

  post "/rooms/:name" do
    if RoomServer.room_exists?(name) do
      case Plug.Conn.get_req_header(conn, "content-type") do
        ["application/json"] ->
          room_from_json(conn, name)
        _ ->
          conn
          |> Plug.put_resp_content_type("application/json")
          |> Plug.send_resp(404, "")
      end
    else
      Plug.Conn.send_resp(conn, 500, "")
    end 
  end

  delete "/rooms/:name" do
    if RoomServer.room_exists?(name) do
      status_code = case RoomServer.delete_room(name) do
        :ok -> 200
        _ -> 500
      end

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(status_code, "")
    else
      Plug.Conn.send_resp(conn, 500, "")
    end
  end

  match _ do
    conn
  end

  def room_to_html(conn, room_name, room_data) do
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, build_html_body(room_name, room_data))
  end

  defp build_html_body(room_name, room_data) do
    EEx.eval_file("templates/room.html.ex", assigns: [room_name: room_name, room_description: get_room_description(room_data)])
  end

  defp get_room_description(room_data), do: room_data |> Keyword.get(:description)

  def room_to_json(conn, room_name, room_data) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, build_json_body(room_name, room_data))
  end

  defp build_json_body(room_name, room_data) do
    "{\"#{room_name}\": { \"connections\": #{inspect Keyword.get(room_data, :connections)}, \"description\": #{inspect Keyword.get(room_data, :description) }}}\n"
  end

  def room_from_json(conn, room_name) do
    status_code = case Plug.Conn.read_body(conn) do
      {:ok, room_description, _} when is_binary(room_description) ->
        case RoomServer.update_description(room_name, room_description) do
          :ok -> 200
          _ -> 500
        end
      _ ->
        400
    end

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status_code, "")
  end
end
