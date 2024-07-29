defmodule Mensaplan.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :avatar, :string
      add :server_id, :bigint
      add :owner_id, references(:users)

      timestamps()
    end

    create unique_index(:groups, [:server_id], nulls_distinct: true)

    create table(:group_members, primary_key: false) do
      add :group_id, references(:groups, on_delete: :delete_all), primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
    end
  end
end
