defmodule Step_3.ParamsHandler do
  require EEx

  def init(request, options) do
    msg = :cowboy_req.binding(:message, request) |> split_underscores_and_join
    reply = request |> build_reply(msg)
    {:ok, reply, options}
  end

  def split_underscores_and_join(string) do
    string
    |> String.split("_")
    |> Enum.join(" ")
    |> String.capitalize
  end

  def build_reply(request, msg) do
    :cowboy_req.reply(status_code(), headers(), body(msg), request)
  end

  def status_code, do: 200
  def headers, do: [{"content-type", "text/html"}]

  def body(msg) do
    EEx.eval_file("templates/index.html.ex", assigns: [message: msg])
  end
end
