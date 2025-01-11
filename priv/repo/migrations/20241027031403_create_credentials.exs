defmodule Notary.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :email, :string, null: false
      add :firstname, :string, null: false
      add :lastname, :string, null: false
      add :password, :string, null: false
    end

    create unique_index(:credentials, [:email])
  end
end
