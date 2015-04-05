defmodule Step_7.SessionsHandler do
  alias Step_7.UserServer

  def init(request, state) do
    {:cowboy_rest, request, []}
  end

  def allowed_methods(request, state) do
    {["POST", "DELETE"], request, state}
  end

  def is_authorized(request, state) do
    case :cowboy_req.method(request) do
      "POST" ->
        {:ok, [{user_data, true}], req2} = :cowboy_req.body_qs(request)
        [user_name, password] = user_data |> Poison.Parser.parse!
        case UserServer.password_match?(user_name, password) do
          true -> {true, req2, Keyword.put(state, :user_name, user_name)}
          false -> {false, request, state}
        end
      "DELETE" ->
        case :cowboy_req.match_cookies([:sessionid], request) do
          %{sessionid: sessionid} when not is_nil(sessionid) -> {true, request, state}
          _ -> {false, request, state}
        end
    end
  end

  def content_types_accepted(request, state) do
    {[
       {{"application", "json", []}, :session_from_json}
      ], request, state}
  end

  def session_from_json(request, state) do
    req2 = :cowboy_req.set_resp_cookie("sessionid", state |> get_user_from_state |> user_hash, [], request)
    {true, req2, state}
  end

  def delete_resource(request, state) do
    req2 = :cowboy_req.set_resp_cookie("sessionid", "", [max_age: 0], request)
    {true, req2, state}
  end

  defp get_user_from_state(state) do
    Keyword.get(state, :user_name)
  end

  defp user_hash(user_name) do
    :crypto.hmac(:sha256, "mysecret", user_name) |> Base.hex_encode32
  end
end
