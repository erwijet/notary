defmodule Notary.Archivist do
  use GenServer

  @impl true
  def init(state) do
    {:ok, state} = schedule_archive_task(state)
    {:ok, state}
  end

  def start_link(_state) do
    # override default state here with a map-- maybe this isn't the best approach? idk but it makes application.ex nicer
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def handle_info(:browse_and_archive, state) do
    Agent.get(Notary.Registrar, & &1)
    |> Map.values()
    |> Enum.filter(&(&1 |> Notary.Registrar.CallbackHandle.is_expired?()))
    |> Enum.map(& &1.key)
    |> Enum.each(&Notary.Registrar.unregister/1)

    {:ok, state} = schedule_archive_task(state)
    {:noreply, state}
  end

  defp schedule_archive_task(state) do
    # 2 min
    Process.send_after(self(), :browse_and_archive, 2 * 60 * 1000)

    {:ok, state}
  end
end
