defmodule Mensaplan.Repo.Migrations.CreatePositions do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :owner_id, references(:users, on_delete: :delete_all)
      add :x, :float
      add :y, :float
      add :public, :boolean, default: true
      add :expired, :boolean, default: false
      add :expires_in, :integer, default: 60 * 60

      timestamps()
    end

    create index(:positions, [:owner_id])
  end
end
