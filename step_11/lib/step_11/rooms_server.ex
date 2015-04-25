defmodule Step_11.RoomServer do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_all_rooms do
    GenServer.call(__MODULE__, :get_all_rooms)
  end

  def get_room(room_name) do
    GenServer.call(__MODULE__, {:get_room, room_name})
  end

  def create_room(room_name) do
    GenServer.cast(__MODULE__, {:add_room, room_name})
  end

  def update_description(room_name, room_description) do
    GenServer.cast(__MODULE__, {:update_description, {room_name, room_description}})
  end

  def delete_room(room_name) do
    GenServer.cast(__MODULE__, {:delete_room, room_name})
  end

  def room_exists?(room_name) do
    GenServer.call(__MODULE__, {:verify_room, room_name})
  end

  def handle_call(:get_all_rooms, _from, state) do
    {:reply, get_all_rooms_from_state(state), state}
  end

  def handle_call({:get_room, room_name}, _from, state) do
    {:reply, get_room_by_name(state, room_name), state}
  end

  def handle_call({:verify_room, room_name}, _from, state) do
    {:reply, does_room_exist?(state, room_name), state}
  end

  def handle_cast({:add_room, room_name}, state) do
    {:noreply, add_room_to_state(state, room_name)}
  end

  def handle_cast({:update_description, {room_name, room_description}}, state) do
    {:noreply, update_room_description(state, room_name, room_description)}
  end

  def handle_cast({:delete_room, room_name}, state) do
    IO.puts "#{room_name} deleted"

    {:noreply, Map.delete(state, room_name |> String.downcase)}
  end

  defp get_all_rooms_from_state(state) do
    Map.keys(state)
  end

  defp get_room_by_name(state, room_name) do
    Map.get(state, room_name |> String.downcase)
  end

  defp add_room_to_state(state, room_name) do
    IO.puts "#{inspect room_name} added"

    Map.put_new(state, room_name |> String.downcase, [connections: [], description: nil])
  end

  defp update_room_description(state, room_name, room_description) do
    Map.update(state, room_name |> String.downcase, [connections: [], description: nil], fn(room_data) ->
      Keyword.update(room_data, :description, nil, fn(_description) -> 
        room_description 
      end)
    end)
  end

  defp does_room_exist?(state, room_name) do
    case Map.get(state, room_name |> String.downcase) do
      nil -> false
      _room_values when is_list(_room_values) -> true
      _ -> false
    end
  end

end
