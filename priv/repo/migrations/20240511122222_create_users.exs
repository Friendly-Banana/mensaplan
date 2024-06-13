defmodule Mensaplan.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :identity, primary_key: true, start_value: 10
      add :auth_id, :string
      add :email, :string
      add :name, :string
      add :avatar, :string
      add :default_public, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    unique_index(:users, [:auth_id])
  end
end
