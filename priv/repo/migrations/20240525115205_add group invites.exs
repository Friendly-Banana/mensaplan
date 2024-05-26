defmodule :"Elixir.Mensaplan.Repo.Migrations.Add group invites" do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :inviter_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:invites, [:uuid])
  end
end
