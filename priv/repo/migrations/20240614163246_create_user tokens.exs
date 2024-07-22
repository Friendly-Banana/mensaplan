defmodule Mensaplan.Repo.Migrations.CreateUsersTokenss do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :token, :binary, null: false

      timestamps(updated_at: false)
    end

    create index(:user_tokens, [:user_id])
    create unique_index(:user_tokens, :token)
  end
end
