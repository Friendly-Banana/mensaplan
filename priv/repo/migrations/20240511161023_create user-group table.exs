defmodule :"Elixir.Mensaplan.Repo.Migrations.Create user-group table" do
  use Ecto.Migration

  def change do
    create table(:group_members, primary_key: false) do
      add :group_id, references(:groups, on_delete: :delete_all), primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
    end
  end
end
