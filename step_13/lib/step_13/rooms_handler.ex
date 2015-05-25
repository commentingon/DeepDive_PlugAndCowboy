defmodule Step_13.RoomsHandler do
  use Plug.Router
  require EEx
  alias Step_13.RoomServer

  plug Plug.Session, store: :cookie, key: "_plug_play", encryption_salt: "mysecret", signing_salt: "mysecret"
  plug Step_13.PutSecretKeyBase

  plug :match
  plug :dispatch

  get "/rooms" do
    send_resp(conn, 200, room_to_html(conn))
  end

  defp show_cookie(cookie), do: IO.puts "Cookie: #{inspect cookie}"

  post "/rooms" do
    case Plug.Conn.get_req_header(conn, "content-type") do
      ["application/json"] ->
        room_from_json(conn)
        send_resp(conn, 200, "success")
      ["application/x-www-form-urlencoded"] ->
        room_from_html(conn)
    end
  end

  match _ do
    conn
  end

  def room_to_html(conn) do
    EEx.eval_file("templates/rooms.html.ex", assigns: [rooms: get_all_rooms(), current_user: get_current_user_name(conn)])
  end

  defp get_all_rooms do
    RoomServer.get_all_rooms
  end

  defp get_current_user_name(conn) do
    conn
    |> fetch_session
    |> get_session(:sessionid)
  end

  defp room_from_json(conn) do
    status_code = case Plug.Conn.read_body(conn) do
      {:ok, room_name, _} when is_binary(room_name) ->
        case RoomServer.create_room(room_name) do
          :ok ->
            RoomServer.update_owners_name(room_name, get_current_user_name(conn))
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
            RoomServer.update_owners_name(room_name, get_current_user_name(conn))
            302
          _ ->
            IO.puts "Unable to create rooms"
            500
        end
      _ ->
        IO.puts "Didn't get the expected data back"
        400
    end

    conn
    |> Plug.Conn.put_resp_header("location", "/rooms")
    |> Plug.Conn.send_resp(status_code, "")
  end
end
