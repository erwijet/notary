defmodule Notary.Client do
  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}
  typed_schema "clients" do
    field(:key, :string, null: false)
    field(:name, :string, null: false)
    field(:google_oauth_client_id, :string)
    field(:notary_host, :string)
  end

  def changeset(struct, params) when is_struct(struct, __MODULE__) do
    struct
    |> cast(params, [:key, :name, :google_oauth_client_id, :notary_host])
    |> validate_required([:key, :name, :notary_host])
    |> unique_constraint(:key, name: :clients_key_index)
    |> unique_constraint(:name, name: :clients_name_index)
  end

  def changeset(map, params) do
    values =
      for key <- ["key", "name", "google_oauth_client_id"] do
        {key, map |> Map.get(key, nil)}
      end

    %{"key" => key, "name" => name, "google_oauth_client_id" => google_oauth_client_id} =
      values |> Enum.into(%{})

    changeset(
      %Notary.Client{
        key: key,
        name: name,
        google_oauth_client_id: google_oauth_client_id
      },
      params
    )
  end
end
