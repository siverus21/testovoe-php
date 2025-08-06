CREATE TABLE categories (
    id   SERIAL PRIMARY KEY,
    name TEXT   UNIQUE NOT NULL
);

CREATE TABLE products (
    id          SERIAL    PRIMARY KEY,
    category_id INT       NOT NULL REFERENCES categories(id),
    name        TEXT      NOT NULL,
    price       NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
    id          BIGSERIAL PRIMARY KEY,
    product_id  INT NOT NULL REFERENCES products(id),
    quantity    INT NOT NULL CHECK (quantity > 0),
    order_time  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE daily_stats (
    stat_date    DATE    NOT NULL,
    product_id   INT     NOT NULL,
    category_id  INT     NOT NULL,
    total_qty    BIGINT  NOT NULL DEFAULT 0,
    UNIQUE (stat_date, product_id, category_id) -- Делаем уникальными, чтобы данные не повторялись в таблице
);

CREATE OR REPLACE FUNCTION stats_for_new_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO daily_stats(stat_date, product_id, category_id, total_qty)
    VALUES (
        NEW.order_time::DATE,
        NEW.product_id,
        (SELECT category_id FROM products WHERE id = NEW.product_id),
        NEW.quantity
    )
    ON CONFLICT (stat_date, product_id, category_id)
    DO UPDATE
      SET total_qty = daily_stats.total_qty + EXCLUDED.total_qty;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_stats_for_new_order
  AFTER INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION stats_for_new_order();

-- Наверное это задание по сложности было на 9/10.
-- Потому что до этого момента я не работал с базой напрямую(через SQL), а пользовался API, в частности API 1c битрикса(на текущем месте работы)
-- Поэтому было тяжеловато с написанием триггера. 
-- Мне триггеры напомнили События из API битрикса, это упростило вникание и понимание, для чего нужны триггеры.
-- По времени ушло примерно 2-3 часа на поверхностное понимание того, что происходит и как с этим взаимодействовать. Наверное просто не хватает практики в этом деле.
-- Постараюсь побольше порешать задач с Code Wars для SQL.
-- Спасибо, что ознакомились и прочитали кооментарии:)