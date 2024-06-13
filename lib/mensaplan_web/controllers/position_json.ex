defmodule MensaplanWeb.PositionJSON do
  alias Mensaplan.Positions.Position

  @doc """
  Renders a list of positions.
  """
  def index(%{positions: positions}) do
    positions
  end

  @doc """
  Renders a single position.
  """
  def show(%{position: %Position{} = position}) do
    %{
      id: position.id,
      owner: position.owner_id,
      x: position.x,
      y: position.y,
      public: position.public,
      expires_in: position.expires_in
    }
  end
end
