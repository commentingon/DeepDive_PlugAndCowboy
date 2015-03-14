defmodule Step_2.Handler do
  def init(request, _options) do
    reply = request |> build_reply
    {:ok, reply, []}
  end

  def build_reply(request) do
    :cowboy_req.reply(status_code(), headers(), body(), request) 
  end

  def status_code, do: 200
  
  def headers, do: [{"content-type", "text/plain"}]
  
  def body, do: "Hello World\n"

end
