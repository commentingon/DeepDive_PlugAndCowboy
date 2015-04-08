defmodule Step_8.UserServer do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_user(user_name) do
    GenServer.call(__MODULE__, {:get_user, make_user_hash(user_name)})
  end

  def get_user_by_hash(user_name_hash) do
    GenServer.call(__MODULE__, {:get_user, user_name_hash})
  end

  def create_user(user_name, password) do
    GenServer.cast(__MODULE__, {:add_user, {user_name, password}})  
  end

  def handle_call({:get_user, user_name}, _from, state) do
    {:reply, get_user_by_name(state, user_name), state}
  end

  def handle_cast({:add_user, user_data}, state) do
    {:noreply, add_user_to_state(state, user_data)}
  end

  defp get_user_by_name(state, user_hash) do
    Map.get(state, user_hash)
  end

  defp add_user_to_state(state, {user_name, password}) do
    IO.puts "New user created: #{user_name}"
    Map.put_new(state, make_user_hash(user_name), [username: user_name, password_hash: make_password_hash(password)])
  end

  defp make_user_hash(user_name) do
    :crypto.hmac(:sha256, "mysecret", user_name) |> Base.hex_encode32
  end

  defp make_password_hash(password) do
    :crypto.hmac(:sha256, "mysecret", password) |> Base.hex_encode32
  end

  def password_match?(user_name, password) do
    user_name
    |> get_user
    |> Keyword.equal?([username: user_name, password_hash: make_password_hash(password)])
  end
end
