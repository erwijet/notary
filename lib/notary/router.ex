defmodule Notary.Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Static, at: "/assets", from: "./portal/build/assets", )

  plug(:dispatch)

  forward("/portal", to: Notary.Portal.Router)

  get "/" do
    conn |> send_file(200, "portal/build/index.html")
  end

  get "/callbacks/google" do
    conn |> send_file(200, "lib/callbacks/google.html")
  end

  #

  get "/handle/:handle_id/:oauth_token" do
    with {:lookup_handle, {:ok, handle}} <- {:lookup_handle, Notary.Registrar.find(handle_id)},
         {:issue_token, {:ok, token}} <-
           {:issue_token,
            Notary.Token.issue_for_client(
              handle.for_client,
              handle.initiator.provider,
              oauth_token
            )} do
      conn
      |> put_resp_header("location", "#{handle.initiator.callback}?token=#{token}")
      |> send_resp(302, "")
    else
      {:lookup_handle, nil} ->
        conn |> send_resp(400, "bad or expired handle key")

      {:issue_token, {:error, issue}} when is_exception(issue) ->
        conn |> send_resp(500, issue |> Exception.message())

      {:issue_token, {:error, issue}} ->
        conn |> send_resp(500, issue |> to_string())
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
