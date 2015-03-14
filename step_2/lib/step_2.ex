defmodule Step_2 do
  def run do
    :cowboy.start_http(:http, 100, [port: 4000], [env: [dispatch: compiled_dispatch_rules()]])
  end

  def compiled_dispatch_rules do
    dispatch_rules |> :cowboy_router.compile
  end

  def dispatch_rules do
    [
      {:_, [
        {'/', Step_2.Handler, []}
      ]}
    ]
  end
end
