defmodule Step_13.PutSecretKeyBase do

  def init(options) do
    options
  end

  def call(conn, _) do
    put_in conn.secret_key_base, "ABCDEFGHIJKLMNOPQRXSTUVWXYZ1234567abcdefghidsgervsawertgesdweqrtqr"
  end
end
