defmodule Notary.Registrar do
  use Agent

  defmodule CallbackHandle do
    @lifetime 60 * 1000
    @type t :: %CallbackHandle{
            provider: String.t(),
            callback: String.t(),
            issued_at: number(),
            key: String.t(),
            for_client: Notary.Client.t()
          }

    defstruct [:key, :provider, :callback, :issued_at, :for_client]

    def is_expired?(%CallbackHandle{:issued_at => issued_at}) do
      System.os_time(:millisecond) > issued_at + @lifetime
    end

    defp rand_key do
      for _ <- 1..10, into: "", do: <<Enum.random(~c"0123456789abcdef")>>
    end

    @spec new(Notary.Client.t(), String.t(), String.t()) :: CallbackHandle.t()
    def new(%Notary.Client{} = client, callback, provider) do
      %CallbackHandle{
        callback: callback,
        provider: provider,
        for_client: client,
        key: rand_key(),
        issued_at: System.os_time(:millisecond)
      }
    end
  end

  def start_link(_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def register(%CallbackHandle{} = handle) do
    Agent.update(__MODULE__, fn old -> old |> Map.put(handle.key, handle) end)
    handle
  end

  @spec issue(Notary.Client.t(), Keyword.t()) :: String.t()
  @doc """
  Issues a new `CallbackHandle` from a client object with a specified provider and callback, returning the handle key.

  ## Examples

  ```elixir
  iex> client = Notary.Repo.all(from c in "clients", where: c.service == "Some Service") |> List.first
  %Notary.Repo.Client{...}

  iex> handle = Notary.Registrar.issue(client,
    via: :google,
    callback: "https://someserver.example.com/auth"
  )
  "0157650fba"
  ```

  """
  def issue(client, options \\ []) do
    provider = options |> Keyword.get(:via)
    callback = options |> Keyword.get(:callback)

    client
    |> Notary.Registrar.CallbackHandle.new(callback, provider)
    |> Notary.Registrar.register()
    |> Map.get(:key)
  end

  @spec keys() :: [String.t()]
  def keys do
    Agent.get(__MODULE__, fn state -> state |> Map.keys() end)
  end

  @spec find(String.t()) :: {:ok, CallbackHandle.t()} | nil
  def find(key) when is_binary(key) do
    item = Agent.get(__MODULE__, fn state -> state |> Map.get(key, nil) end)

    unless item |> is_nil do
      {:ok, item}
    else
      nil
    end
  end

  @spec unregister(String.t()) :: {:ok, CallbackHandle.t()} | {:not_found}
  def unregister(key) do
    case find(key) do
      {:ok, handle} ->
        Agent.update(__MODULE__, fn state -> state |> Map.drop([key]) end)
        {:ok, handle}

      nil ->
        {:not_found}
    end
  end
end
