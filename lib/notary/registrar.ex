defmodule Notary.Registrar do
  alias Notary.Proto.GoogleOauth2AuthPageReq

  use Agent

  defmodule CallbackHandle do
    @lifetime 60 * 1000
    @type t :: %CallbackHandle{
            initiator: GoogleOauth2AuthPageReq.t(),
            issued_at: number(),
            key: String.t(),
            for_client: Notary.Client.t()
          }

    alias Notary.Proto.GoogleOauth2AuthPageReq
    defstruct [:key, :initiator, :issued_at, :for_client]

    def is_expired?(%CallbackHandle{:issued_at => issued_at}) do
      System.os_time(:millisecond) > issued_at + @lifetime
    end

    defp rand_key do
      for _ <- 1..10, into: "", do: <<Enum.random(~c"0123456789abcdef")>>
    end

    def new(%GoogleOauth2AuthPageReq{} = initiator, %Notary.Client{} = client) do
      %CallbackHandle{
        initiator: initiator,
        key: rand_key(),
        issued_at: System.os_time(:millisecond),
        for_client: client
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
