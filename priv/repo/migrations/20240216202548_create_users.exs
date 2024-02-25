defmodule Notary.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :given_name, :string, null: false
      add :family_name, :string, null: false
      add :email, :string, null: false
      add :picture, :string, null: false
      add :created_at, :integer, null: false
    end
  end
end
