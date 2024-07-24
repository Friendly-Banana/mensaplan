defmodule :"Elixir.Mensaplan.Repo.Migrations.One invite per group" do
  use Ecto.Migration

  def up do
    alter table(:groups) do
      add :invite, :uuid, autogenerate: true
    end

    create unique_index(:groups, [:invite])

    # preserve existing invites
    execute "UPDATE groups SET invite = invites.uuid FROM invites WHERE groups.id = invites.group_id"

    drop table(:invites), mode: :cascade
  end

  def down do
    create table(:invites, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :group_id, references(:groups, on_delete: :delete_all)
      add :inviter_id, references(:users, on_delete: :delete_all)

      timestamps(default: fragment("NOW()"))
    end

    create index(:invites, [:uuid])

    # restore invites
    execute "INSERT INTO invites (uuid, group_id, inviter_id) SELECT g.invite, g.id, g.owner_id FROM groups g WHERE g.invite IS NOT NULL"

    drop index(:groups, [:invite])

    alter table(:groups) do
      remove :invite
    end
  end
end
