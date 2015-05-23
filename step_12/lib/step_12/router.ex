defmodule Step_12.Router do
  use Plug.Builder

  plug Step_12.HomeHandler
  plug Plug.Static, at: "/js", from: {:step_12, "priv/js"}
  plug Plug.Static, at: "/css", from: {:step_12, "priv/css"}

  plug Step_12.RoomHandler
  plug Step_12.RoomsHandler
end
