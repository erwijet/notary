defmodule Notary.Repo.Migrations.ClientsNotaryHost do
  use Ecto.Migration

  def up do
    alter table(:clients) do
      add :notary_host, :string
    end

    execute("UPDATE clients SET notary_host = 'notary.holewisnki.dev'")

    alter table(:clients) do
      modify :notary_host, :string, null: false
    end
  end

  def down do
    alter table(:clients) do
      remove :notary_host
    end
  end
end
