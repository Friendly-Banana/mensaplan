defmodule :"Elixir.Mensaplan.Repo.Migrations.Create dishes" do
  use Ecto.Migration

  def change do
    create table(:dishes, primary_key: false) do
      add :name, :string, primary_key: true
      add :price, :string
      add :category, :string
    end

    create table(:likes, primary_key: false) do
      add :like, :boolean
      add :user_id, references(:users), primary_key: true
      add :dish_id, references(:dishes), primary_key: true
    end
  end
end
