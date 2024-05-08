defmodule Mensaplan.Repo.Migrations.CreatePositions do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :x, :float
      add :y, :float

      timestamps(type: :utc_datetime)
    end
  end
end
