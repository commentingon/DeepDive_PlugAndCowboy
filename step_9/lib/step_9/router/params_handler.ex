defmodule Step_9.Router.ParamsHandler do
  import Plug.Conn
  require EEx

  def build_reply(conn, params) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(status_code(), body(params))
  end

  defp status_code, do: 200
  
  defp body(params) do
    EEx.eval_file("templates/index.html.ex", assigns: params)
  end
end
