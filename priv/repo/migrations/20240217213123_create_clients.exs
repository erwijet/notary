defmodule Notary.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :key, :string, null: false
      add :name, :string, null: false
      add :google_oauth_client_id, :string
    end
  end
end
