defmodule Step_8.UsersHandler do
  require EEx
  alias Step_8.UserServer

  def init(request, _options) do
    {:cowboy_rest, request, []}
  end

  def allowed_methods(request, state) do
    {["POST"], request, state}
  end

  def content_types_accepted(request, state) do
    {[
        {{"application", "json", []}, :user_from_json}
      ], request, state}
  end

  def user_from_json(request, state) do
    {:ok, [{user_data, true}], req2} = :cowboy_req.body_qs(request)
    case user_data |> Poison.Parser.parse! do
      [user_name, password, password_conf] when password == password_conf ->
        case UserServer.create_user(user_name, password) do
          :ok -> {true, req2, state}
          _ -> {false, req2, state}
        end
      _ -> {false, req2, state}
    end
  end
end
