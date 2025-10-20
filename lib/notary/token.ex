defmodule Notary.Token do
  use Joken.Config

  # expire tokens after 3 hours
  @lifetime 3 * 60 * 60

  @impl true
  def token_config do
    default_claims(skip: [:iss, :aud], default_exp: @lifetime)
    |> add_claim("iss", fn -> "Notary" end, &(&1 == "Notary"))
  end

  @spec renew(Joken.bearer_token()) ::
          {:ok, Joken.bearer_token()} | {:error, Joken.error_reason()}
  def renew(token) do
    with {:ok, claims} <- Notary.Token.verify_and_validate(token),
         {:ok, renewed, _claims} <-
           generate_and_sign(
             claims
             |> Map.take([
               "aud",
               "via",
               "sub",
               "user_id",
               "fullname",
               "given_name",
               "family_name",
               "picture"
             ])
           ) do
      {:ok, renewed}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec issue_for_client(Notary.Client.t(), String.t(), String.t()) ::
          {:ok, Joken.bearer_token()} | {:error, Joken.error_reason() | Exception.t()}
  def issue_for_client(client, provider, oauth_tok) do
    with {:ok, user} <- Notary.User.fetch(provider |> String.to_atom(), oauth_tok),
         {:ok, token, _claims} <-
           generate_and_sign(%{
             "aud" => client.name,
             "via" => provider,
             "sub" => user.email,
             "user_id" => user.id,
             "fullname" => user.name,
             "given_name" => user.given_name,
             "family_name" => user.family_name,
             "picture" => user.picture
           }) do
      {:ok, token}
    else
      {:error, issue} -> {:error, issue}
    end
  end
end
