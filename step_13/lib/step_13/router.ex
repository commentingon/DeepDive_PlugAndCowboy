defmodule Step_13.Router do
  use Plug.Builder

  plug Step_13.HomeHandler
  plug Plug.Static, at: "/js", from: {:step_13, "priv/js"}
  plug Plug.Static, at: "/css", from: {:step_13, "priv/css"}

  plug Step_13.RoomHandler
  plug Step_13.RoomsHandler
  plug Step_13.UsersHandler
  plug Step_13.SessionsHandler
end
