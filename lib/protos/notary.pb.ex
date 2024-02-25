defmodule Notary.Proto.Oauth2Provider do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:google, 0)
end

defmodule Notary.Proto.User do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:id, 1, type: :uint64)
  field(:given_name, 2, type: :string, json_name: "givenName")
  field(:family_name, 3, type: :string, json_name: "familyName")
  field(:picture, 4, type: :string)
  field(:email, 5, type: :string)
  field(:created_at, 6, type: :uint64, json_name: "createdAt")
end

defmodule Notary.Proto.Authority do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:service, 1, type: :string)
  field(:key, 2, type: :string)
end

defmodule Notary.Proto.GoogleOauth2AuthPageReq do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:authority, 1, type: Notary.Proto.Authority)
  field(:provider, 2, type: Notary.Proto.Oauth2Provider, enum: true)
  field(:callback, 3, type: :string)
end

defmodule Notary.Proto.OauthPage do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:url, 1, type: :string)
end

defmodule Notary.Proto.GetUserReq do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:authoriy, 1, type: Notary.Proto.Authority)
  field(:provider, 2, type: Notary.Proto.Oauth2Provider, enum: true)
  field(:notary_token, 3, type: :string, json_name: "notaryToken")
end

defmodule Notary.Proto.NotaryToken do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:jwt, 1, type: :string)
  field(:user, 2, type: Notary.Proto.User)
end

defmodule Notary.Proto.OAuth2.Service do
  @moduledoc false

  use GRPC.Service, name: "notary.proto.OAuth2", protoc_gen_elixir_version: "0.12.0"

  rpc(:get_oauth2_page, Notary.Proto.GoogleOauth2AuthPageReq, Notary.Proto.OauthPage)

  rpc(:get_user, Notary.Proto.GetUserReq, Notary.Proto.User)
end

defmodule Notary.Proto.OAuth2.Stub do
  @moduledoc false

  use GRPC.Stub, service: Notary.Proto.OAuth2.Service
end
