defmodule Notary.Router do
  alias Notary.Registrar
  use Plug.Router

  import Ecto.Query, only: [from: 2]

  plug(:match)

  plug(Plug.Static, at: "/assets", from: "./portal/build/assets")

  plug(:dispatch)

  forward("/portal", to: Notary.Portal.Router)

  get "/" do
    conn |> send_file(200, "portal/build/index.html")
  end

  get "/authorize/:service" do
    with %{"via" => provider, "key" => key, "callback" => callback} <-
           conn |> fetch_query_params() |> Map.get(:query_params),
         client when not is_nil(client) <-
           Notary.Repo.all(from(c in Notary.Client, where: c.name == ^service and c.key == ^key))
           |> List.first(),
         true <- provider in ["google"] do
      handle =
        Notary.Registrar.issue(client,
          via: provider,
          callback: callback
        )

      url =
        case provider do
          "google" ->
            "https://accounts.google.com/o/oauth2/auth?client_id=#{client.google_oauth_client_id}&redirect_uri=#{Application.fetch_env!(:notary, :hostname)}/callbacks/google&scope=openid+email+profile&email&response_type=token&state=#{handle}"
        end

      conn |> send_resp(200, %{"url" => url} |> Jason.encode!())
    else
      issue ->
        issue |> IO.inspect()
        conn |> send_resp(400, "bad request")
    end
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
              handle.provider,
              oauth_token
            )} do
      conn
      |> put_resp_header("location", "#{handle.callback}?token=#{token}")
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
