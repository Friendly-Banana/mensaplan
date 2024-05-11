defmodule MensaplanWeb.GroupJSON do
  alias Mensaplan.Accounts.Group

  @doc """
  Renders a list of groups.
  """
  def index(%{groups: groups}) do
    %{data: for(group <- groups, do: data(group))}
  end

  @doc """
  Renders a single group.
  """
  def show(%{group: group}) do
    %{data: data(group)}
  end

  defp data(%Group{} = group) do
    %{
      id: group.id,
      name: group.name,
      avatar: group.avatar
    }
  end
end
