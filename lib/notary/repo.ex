defmodule Notary.Repo do
  use Ecto.Repo,
    otp_app: :notary,
    adapter: Ecto.Adapters.Postgres
end
