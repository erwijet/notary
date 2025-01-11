defmodule Notary.Credentials do
  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}
  typed_schema "credentials" do
    field(:email, :string, null: false)
    field(:firstname, :string, null: false)
    field(:lastname, :string, null: false)
    field(:password, :string, null: false)
  end

  def changeset(struct, params) when is_struct(struct, __MODULE__) do
    struct
    |> cast(params, [:email, :firstname, :lastname, :password])
    |> validate_required([:email, :firstname, :lastname, :password])
    |> unique_constraint(:email, name: :credentials_email_index)
  end

  def changeset(map, params) do
    values =
      for key <- ["email", "firstname", "lastname", "password"] do
        {key, map |> Map.get(key, nil)}
      end

    %{"email" => email, "firstname" => firstname, "lastname" => lastname, "password" => password} =
      values |> Enum.into(%{})

    changeset(
      %Notary.Credentials{
        email: email,
        firstname: firstname,
        lastname: lastname,
        password: password
      },
      params
    )
  end
end
