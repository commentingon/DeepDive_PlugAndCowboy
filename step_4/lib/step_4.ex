defmodule Step_4 do
  use Application

  def start(_types, _args) do
    start_server(4000)
  end

  defp start_server(port) do
    :cowboy.start_http(:http, 100, [port: port], [env: [dispatch: dispatch_rules()]])
  end

  defp dispatch_rules do
    :cowboy_router.compile(host_matches())
  end

  defp host_matches do
    [{:_, 
      path_matches()
    }]
  end

  defp path_matches do
    [
      {"/", Step_4.Handler, [message: "Hello From a Stylish Template"]},
      {"/js/[...]", :cowboy_static, {:priv_dir, :step_4, "/js"}},
      {"/css/[...]", :cowboy_static, {:priv_dir, :step_4, "/css"}}
    ]
  end
end
