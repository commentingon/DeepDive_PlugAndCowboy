defmodule Step_12.RoomHandler do
  use Plug.Router
  require EEx
  alias Step_12.RoomServer

  plug :match
  plug :dispatch

  get "/rooms/:name" do
    if RoomServer.room_exists?(name) && is_authorized(conn, name) do
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
    # IO.puts "Room Data: #{inspect room_data}"
    EEx.eval_file("templates/room.html.ex", assigns: [room_name: room_name, room_description: get_room_description(room_data), password_set: get_password_set(room_data)])
  end

  defp get_room_description(room_data), do: room_data |> Keyword.get(:description)

  defp get_password_set(room_data) do
    room_data |> Keyword.get(:password) |> is_password
  end

  defp is_password(password) when is_nil(password), do: false

  defp is_password(_), do: true

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
      {:ok, update_data, _} ->
        case update_room(room_name, Poison.Parser.parse!(update_data)) do
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

  def update_room(room_name, ["description", description]) do
    RoomServer.update_description(room_name, description)
  end

  def update_room(room_name, ["password", password]) do
    RoomServer.update_password(room_name, password)
  end

  # Inspired by plug_basic_auth at: https://github.com/rbishop/plug_basic_auth/blob/master/lib/plug_basic_auth.ex
  def is_authorized(conn, room_name) do
    case RoomServer.room_has_password?(room_name) do
      {true, {_, room_password}} ->
        conn
        |> parse_auth_header
        |> match_credentials(room_password)
      _ ->
        true
    end
  end

  def parse_auth_header(conn) do
    decode_resp(conn, Plug.Conn.get_req_header(conn, "authorization"))
  end

  def decode_resp(conn, ["Basic " <> req_password]) do 
    ":" <> decoded_password = Base.decode64!(req_password)
    {conn, decoded_password}
  end

  def decode_resp(conn, []), do: {conn, nil}

  def match_credentials({_, req_password}, room_password) when req_password == room_password, do: true

  def match_credentials({conn, _}, _) do
    conn
    |> Plug.Conn.put_resp_header("WWW-Authenticate", "Basic realm=\"plug\"")
    |> send_resp(401, "")
    |> halt
  end
end
