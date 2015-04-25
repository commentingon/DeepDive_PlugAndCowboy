defmodule Step_11.Router do
  use Plug.Builder

  plug Step_11.HomeHandler
  plug Plug.Static, at: "/js", from: {:step_11, "priv/js"}
  plug Plug.Static, at: "/css", from: {:step_11, "priv/css"}

  plug Step_11.RoomHandler
  plug Step_11.RoomsHandler
end
