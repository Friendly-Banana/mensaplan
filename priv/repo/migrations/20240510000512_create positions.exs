defmodule :"Elixir.Mensaplan.Repo.Migrations.Create positions" do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :user, :string
      add :x, :float
      add :y, :float

      timestamps(type: :utc_datetime)
    end
    create unique_index(:positions, [:user])
  end
end
