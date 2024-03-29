defmodule Notary.Helpers do
  import Plug.Conn

  @spec send_json(Plug.Conn.t(), map(), Keyword.t()) :: Plug.Conn.t()
  def send_json(conn, body, options \\ []) do
    status = options |> Keyword.get(:code, 200)

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, body |> Jason.encode!())
  end
end
