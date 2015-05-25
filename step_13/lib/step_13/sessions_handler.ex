defmodule Step_13.SessionsHandler do
  use Plug.Router
  alias Step_13.UserServer
  
  plug Plug.Session, store: :cookie, key: "_plug_play", encryption_salt: "mysecret", signing_salt: "mysecret"
  plug Step_13.PutSecretKeyBase

  plug :match
  plug :dispatch

  post "/sessions" do
    {:ok, user_data, _} = Plug.Conn.read_body(conn)
    [user_name, password] = user_data |> Poison.Parser.parse!
    case UserServer.password_match?(user_name, password) do
      true ->
        conn
        |> fetch_session
        |> put_session(:sessionid, user_name)
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "")
      false -> 
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(500, "")
    end
  end

  delete "/sessions" do
    conn
    |> fetch_session
    |> delete_session(:sessionid)
    |> Plug.Conn.send_resp(200, "")
  end

  match _ do
    conn
  end
end
