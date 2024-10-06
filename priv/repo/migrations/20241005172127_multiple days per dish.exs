defmodule :"Elixir.Mensaplan.Repo.Migrations.Multiple days per dish" do
  use Ecto.Migration

  def up do
    create table(:dish_dates, primary_key: false) do
      add :dish_id, references(:dishes, on_delete: :delete_all), primary_key: true
      add :date, :date, primary_key: true
    end

    create index(:dish_dates, [:dish_id])

    execute("""
    INSERT INTO dish_dates (dish_id, date)
    SELECT id, date FROM dishes
    """)

    alter table(:dishes) do
      remove :date
    end
  end

  def down do
    alter table(:dishes) do
      add :date, :date
    end

    execute("""
    UPDATE dishes
    SET date = (SELECT date FROM dish_dates WHERE dish_dates.dish_id = dishes.id LIMIT 1)
    """)

    drop table(:dish_dates)
  end
end
