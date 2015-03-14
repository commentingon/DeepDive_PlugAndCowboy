defmodule Step_4.Handler do
  require EEx

  def init(request, options) do
    reply = request |> build_reply(options)
    {:ok, reply, options}
  end

  def build_reply(request, options) do
    :cowboy_req.reply(status_code(), headers(), body(options), request)
  end

  def status_code, do: 200
  def headers, do: [{"content-type", "text/html"}]

  def body(params) do
    EEx.eval_file("templates/index.html.ex", assigns: params)
  end
end
