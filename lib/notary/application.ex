defmodule Notary.Endpoint do
  use GRPC.Endpoint

  intercept(GRPC.Server.Interceptors.Logger)
  run(Notary.Services.OAuth2.Server)
end

defmodule Notary.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {GRPC.Server.Supervisor, endpoint: Notary.Endpoint, port: 50052, start_server: true},
      {Plug.Cowboy, scheme: :http, plug: Notary.Router, options: [port: 8080]},
      Notary.Registrar,
      Notary.Archivist,
      Notary.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Notary.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
