defmodule Notary.Portal.Router do
  use Plug.Router

  import Notary.Helpers

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/auth" do
    with %{"passkey" => passkey} <- conn.body_params do
      {:ok, expected_key} = Application.fetch_env(:notary, :portal_passkey)

      case passkey do
        ^expected_key ->
          token = Notary.Portal.Token.generate_and_sign!()
          conn |> send_json(%{"token" => token})
        _ ->
          conn |> send_resp(422, "invalid")
      end
    else
      _ -> conn |> send_resp(400, "expected 'passkey'")
    end
  end

  defmodule Protected do
    use Plug.Router

    plug(:match)

    plug(Plug.Parsers,
      parsers: [:json],
      pass: ["application/json"],
      json_decoder: Jason
    )

    # require token auth
    plug(Notary.Portal.Token)

    plug(:dispatch)

    get "/clients" do
      clients = Notary.Repo.all(Notary.Client)
      conn |> send_json(%{ "clients" => clients })
    end

    get "/clients/:id" do
      with {id, _} <- Integer.parse(id),
           client when not is_nil(client) <- Notary.Repo.get(Notary.Client, id) do
        conn |> send_json(client)
      else
        _ -> conn |> send_resp(404, "not found")
      end
    end

    post "/clients" do
      proposed = Notary.Client.changeset(conn.body_params, %{})

      if proposed.valid? do
        case Notary.Repo.insert(proposed) do
          {:ok, inserted} -> conn |> send_json(inserted, code: 201)
          _ -> conn |> send_resp(409, "conflict")
        end
      else
        conn |> send_resp(412, "malformed 'Client' struct")
      end
    end

    put "/clients/:id" do
      with {id, _} <- Integer.parse(id),
           base when not is_nil(base) <- Notary.Repo.get(Notary.Client, id) do
        case Notary.Client.changeset(base, conn.body_params) |> Notary.Repo.update() do
          {:ok, updated} -> conn |> send_json(updated)
          _ -> conn |> send_resp(409, "conflict")
        end
      else
        _ -> conn |> send_resp(404, "not found")
      end
    end

    delete "/clients/:id" do
      with {id, _} <- Integer.parse(id),
           staged when not is_nil(staged) <- Notary.Repo.get(Notary.Client, id) do
        {:ok, deleted} = Notary.Repo.delete(staged)
        conn |> send_json(deleted)
      else
        _ -> conn |> send_resp(404, "not found")
      end
    end

    match _ do
      conn |> send_resp(404, "not found")
    end
  end

  match _ do
    Protected.call(conn, [])
  end
end
