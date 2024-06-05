defmodule Mensaplan.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :avatar, :string
      add :server_id, :integer
      add :owner_id, references(:users)

      timestamps(type: :utc_datetime)
    end

    unique_index(:users, [:server_id])
  end
end
