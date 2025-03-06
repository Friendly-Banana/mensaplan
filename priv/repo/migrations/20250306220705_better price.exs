defmodule :"Elixir.Mensaplan.Repo.Migrations.Better price" do
  use Ecto.Migration

  def up do
    alter table(:dishes) do
      add :fixed_price, :integer
      add :price_per_unit, :integer
    end

    execute """
    UPDATE dishes
    SET
      fixed_price =
        CASE
          WHEN price LIKE '%+%' THEN
            CAST(REPLACE(SUBSTRING(price FROM 1 FOR STRPOS(price, '+') - 3), '.', '') AS INTEGER)
          ELSE
            0
        END,
      price_per_unit =
        CASE
          WHEN price LIKE '%+%' THEN
              CAST(REPLACE(REPLACE(TRIM(SUBSTRING(price FROM STRPOS(price, '+') + 1 FOR LENGTH(price) - STRPOS(price, '+'))), '€/100g', ''), '.', '') AS INTEGER)
          WHEN price LIKE '%/100g%' THEN
              CAST(REPLACE(TRIM(REPLACE(price, '€/100g', '')), '.', '') AS INTEGER)
          ELSE
              0
        END
    """

    alter table(:dishes) do
      remove :price
    end
  end

  def down do
    alter table(:dishes) do
      add :price, :string
    end

    execute """
    UPDATE dishes
    SET price =
      CASE
        WHEN fixed_price > 0 AND price_per_unit > 0 THEN
          ROUND(fixed_price / 100.0, 2) || '€ + ' || ROUND(price_per_unit / 100.0, 2) || '€/100g'
        WHEN price_per_unit > 0 THEN
          ROUND(price_per_unit / 100.0, 2) || '€/100g'
        ELSE
          ROUND(fixed_price / 100.0, 2) || '€'
      END
    """

    alter table(:dishes) do
      remove :fixed_price
      remove :price_per_unit
    end
  end
end
