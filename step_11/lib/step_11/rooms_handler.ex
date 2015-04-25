defmodule Step_11.RoomsHandler do
  use Plug.Router
  require EEx
  alias Step_11.RoomServer

  plug :match
  plug :dispatch

  get "/rooms" do
    send_resp(conn, 200, rooms_to_html())
  end

  post "/rooms" do
    case Plug.Conn.get_req_header(conn, "content-type") do
      ["application/json"]->
        room_from_json(conn)
        send_resp(conn, 200, "success")
      ["application/x-www-form-urlencoded"] ->
        room_from_html(conn)
    end
  end

  match _ do
    conn
  end

  def rooms_to_html do
    EEx.eval_file("templates/rooms.html.ex", assigns: [rooms: get_all_rooms()])
  end

  defp get_all_rooms do
    RoomServer.get_all_rooms
  end

  defp room_from_json(conn) do
    status_code = case Plug.Conn.read_body(conn) do
      {:ok, room_name, _} when is_binary(room_name) ->
        case RoomServer.create_room(room_name) do
          :ok ->
            200
          _ ->
            500
        end
      _ ->
        400
    end

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status_code, "")
  end

  defp room_from_html(conn) do
    status_code = case Plug.Conn.read_body(conn) do
      {:ok, "roomName=" <> room_name, _} ->  
        case RoomServer.create_room(room_name) do
          :ok ->
            302
          _ ->
            IO.puts "Unable to create room"
            500
        end
      _ ->
        IO.puts "didn't get the expected data back"
        400
    end

    conn
    |> Plug.Conn.put_resp_header("location", "/rooms")
    |> Plug.Conn.send_resp(status_code, "")
  end
end
