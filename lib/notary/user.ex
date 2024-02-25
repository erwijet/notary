defmodule Notary.User do
  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          given_name: String.t(),
          family_name: String.t(),
          email: String.t(),
          picture: String.t()
        }

  defstruct [:id, :name, :given_name, :family_name, :email, :picture]

  @spec from(map()) :: {:ok, t()} | {:error, Exception.t()}
  def from(map) when is_map(map) do
    keys = %__MODULE__{} |> Map.keys()

    try do
      new =
        for({k, v} <- map, do: {String.to_atom(k), v})
        |> Enum.filter(fn {k, _v} -> k in keys end)
        |> (&struct!(__MODULE__, &1)).()

      {:ok, new}
    rescue
      e in KeyError -> {:error, e}
    end
  end

  ##

  @spec fetch(:google, String.t()) :: {:ok, t()} | {:error, Exception.t()}
  def fetch(:google, oauth_token) do
    fetch_via_google(oauth_token)
  end

  @spec fetch_via_google(String.t()) :: {:ok, t()} | {:error, Exception.t()}
  defp fetch_via_google(oauth_token) do
    with {:ok, %{:body => body}} <-
           Req.get(
             "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=#{oauth_token}"
           ),
         {:ok, user} <- from(body) do
      {:ok, user}
    else
      {:error, exception} -> {:error, exception}
    end
  end
end
