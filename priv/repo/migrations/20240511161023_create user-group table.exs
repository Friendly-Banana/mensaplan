defmodule :"Elixir.Mensaplan.Repo.Migrations.Create user-group table" do
  use Ecto.Migration

  def change do
    create table(:group_members) do
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:group_members, [:group_id])
    create index(:group_members, [:user_id])
  end
end
