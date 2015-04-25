defmodule Step_10.Router do
  use Plug.Builder

  plug Step_10.Handler
  plug Plug.Static, at: "/js", from: {:step_10, "priv/js"}
  plug Plug.Static, at: "/css", from: {:step_10, "priv/css"}

end
