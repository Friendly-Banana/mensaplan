defmodule Mensaplan.Periodically do
  use GenServer

  import Ecto.Query, warn: false
  alias Mensaplan.Positions.Position
  alias Mensaplan.Repo
  require Logger

  # https://stackoverflow.com/a/32097971/12846952

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_expiration()
    {:ok, state}
  end

  def handle_info(:expire_positions, state) do
    Logger.info("Expiring positions...")

    from(p in Position,
      where:
        not p.expired and fragment("? + interval '1 minute' * ? <= now()", p.inserted_at, p.expires_in)
    )
    |> Repo.update_all(set: [expired: true])

    # Reschedule once more
    schedule_expiration()
    {:noreply, state}
  end

  defp schedule_expiration() do
    Process.send_after(self(), :expire_positions, 5 * 60 * 1000)
  end
end
