defmodule Step_9.Handler do
  use Plug.Router
  require EEx

  plug :match
  plug :dispatch

  match "/" do
    send_resp(conn, status_code(), body([message: "Hello from a template"]))
  end

  match "/:message" do
    send_resp(conn, status_code(), body([message: message |> split_underscores_and_join]))
  end

  defp status_code, do: 200

  defp body(params) do
    EEx.eval_file("templates/index.html.ex", assigns: params)
  end

  defp split_underscores_and_join(string) do
    string
    |> String.split("_")
    |> Enum.join(" ")
    |> String.capitalize
  end
end
