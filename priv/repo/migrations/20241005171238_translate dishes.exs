defmodule :"Elixir.Mensaplan.Repo.Migrations.Translate dishes" do
  use Ecto.Migration

  def change do
    rename table(:dishes), :name, to: :name_de

    alter table(:dishes) do
      add :name_en, :string
    end
  end
end
