defmodule Notary.Repo.Migrations.CreateUsersUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:clients, [:key])
    create unique_index(:clients, [:name])
  end
end
