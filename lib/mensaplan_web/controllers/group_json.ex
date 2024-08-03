defmodule MensaplanWeb.GroupJSON do
  @doc """
  Renders a list of groups.
  """
  def index(%{groups: groups}) do
    for(group <- groups, do: data(group))
  end

  @doc """
  Renders a single group.
  """
  def show(%{group: group}) do
    data(group)
  end

  defp data(group) do
    %{
      id: group.id,
      name: group.name,
      avatar: group.avatar,
      server_id: Map.get(group, :server_id),
      owner_id: group.owner_id
    }
  end
end
