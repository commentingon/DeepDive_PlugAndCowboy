defmodule Step_13.UsersHandler do
  use Plug.Router
  alias Step_13.UserServer

  plug :match
  plug :dispatch

  post "/users" do
    case Plug.Conn.get_req_header(conn, "content-type") do
      ["application/json"] ->
        if user_from_json(conn) do
          send_resp(conn, 200, "success")
        else
          send_resp(conn, 500, "")
        end
      _ ->
        send_resp(conn, 500, "")
    end
  end

  match _ do
    conn
  end

  defp user_from_json(conn) do
    {:ok, user_data, _} = Plug.Conn.read_body(conn)
    case user_data |> Poison.Parser.parse! do
      [user_name, password, password_conf] when password == password_conf ->
        case UserServer.create_user(user_name, password) do
          :ok -> true
          _ -> false
        end
      _ ->
        false
    end
  end
end
