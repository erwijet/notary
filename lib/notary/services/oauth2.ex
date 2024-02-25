defmodule Notary.Services.OAuth2.Server do
  alias Notary.Proto
  import Ecto.Query, only: [from: 2]
  use GRPC.Server, service: Proto.OAuth2.Service

  @spec get_oauth2_page(Notary.Proto.GoogleOauth2AuthPageReq.t(), any()) ::
          Notary.Proto.OauthPage.t()
  def get_oauth2_page(req, _stream) do
    %Proto.GoogleOauth2AuthPageReq{
      :authority => authority,
      :provider => provider
    } =
      req

    with client when not is_nil(client) <-
           Notary.Repo.all(
             from(c in Notary.Client,
               where: c.name == ^authority.service and c.key == ^authority.key
             )
           )
           |> List.first(),
         true <- provider in [:google] do
      state =
        req
        |> Notary.Registrar.CallbackHandle.new(client)
        |> Notary.Registrar.register()
        |> Map.get(:key)

      url =
        case provider do
          :google ->
            "https://accounts.google.com/o/oauth2/auth?client_id=#{client.google_oauth_client_id}&redirect_uri=http://localhost:8080/callbacks/google&scope=openid+email+profile&email&response_type=token&state=#{state}"
        end

      %Proto.OauthPage{url: url}
    else
      issue ->
        issue |> IO.inspect()
        GRPC.Status.unauthenticated()
    end
  end
end
