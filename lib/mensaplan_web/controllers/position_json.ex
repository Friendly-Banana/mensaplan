defmodule MensaplanWeb.PositionJSON do
  alias Mensaplan.Positions.Position

  @doc """
  Renders a list of positions.
  """
  def index(%{positions: positions}) do
    for(position <- positions, do: data(position))
  end

  @doc """
  Renders a single position.
  """
  def show(%{position: position}) do
    data(position)
  end

  defp data(%Position{} = position) do
    %{
      id: position.id,
      owner: position.owner_id,
      x: position.x,
      y: position.y,
      public: position.public,
      expired: position.expired,
      expires_in: position.expires_in,
      inserted_at: position.inserted_at,
      updated_at: position.updated_at
    }
  end
end
