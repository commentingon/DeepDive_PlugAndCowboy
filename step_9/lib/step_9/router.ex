defmodule Step_9.Router do
  import Plug.Conn
  alias Plug.Conn
  alias Step_9.Router.Handler
  alias Step_9.Router.ParamsHandler

  def init(options) do
    options
  end

  def call(conn = %Conn{path_info: []}, _opts) do
    conn |> Handler.build_reply
  end

  def call(conn = %Conn{path_info: [message]}, _opts) do
    conn |> ParamsHandler.build_reply([message: message |> split_underscores_and_join])
  end

  defp split_underscores_and_join(string) do
    string
    |> String.split("_")
    |> Enum.join(" ")
    |> String.capitalize
  end
end
