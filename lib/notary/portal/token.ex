defmodule Notary.Portal.Token do
  @behaviour Plug

  use Joken.Config
  import Plug.Conn

  @impl true
  def token_config do
    default_claims(skip: [:iss, :aud])
    |> add_claim("iss", fn -> "Notary" end, &(&1 == "Notary"))
    |> add_claim("aud", fn -> "Notary_Portal" end, &(&1 == "Notary_Portal"))
  end

  @impl true
  def init(opts), do: opts

  defp check_nil(val) when is_nil(val), do: {nil}
  defp check_nil(val), do: {:ok, val}

  defp extract_authorization_header(req_headers) do
    req_headers
    |> Enum.find_value(fn
      {"authorization", authorization} -> authorization
      _ -> nil
    end)
    |> check_nil
  end

  defp extract_bearer(tok), do: tok |> String.trim_leading("Bearer ")

  @impl true
  def call(conn, _opts) do
    with {:ok, tok} <- extract_authorization_header(conn.req_headers),
         bearer <- extract_bearer(tok),
         {:ok, _claims} <- verify_and_validate(bearer) do
      conn
    else
      issue ->
        issue |> IO.inspect()
        conn |> send_resp(401, "unauthorized") |> halt
    end
  end
end
