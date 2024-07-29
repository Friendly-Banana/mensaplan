defmodule Mensaplan.Repo.Migrations.CreateDishes do
  use Ecto.Migration

  def change do
    create table(:dishes) do
      add :name, :string
      add :price, :string
      add :category, :string
      add :date, :date, default: fragment("CURRENT_DATE")
    end

    create unique_index(:dishes, [:name])

    create table(:likes, primary_key: false) do
      add :like, :integer
      add :user_id, references(:users), primary_key: true
      add :dish_id, references(:dishes), primary_key: true
    end

    create unique_index(:likes, [:user_id, :dish_id])
  end
end
