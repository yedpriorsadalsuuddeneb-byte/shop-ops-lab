-- shop-ops-lab seed: resets shop_db to its starting ("broken") state.
-- Safe to run again and again. All data is synthetic.

-- 0. Close other sessions on this database (e.g. DBeaver) so nothing blocks the reset
SELECT pg_terminate_backend(pid) FROM pg_stat_activity
WHERE datname = current_database() AND pid <> pg_backend_pid();

-- 1. Remove the two application roles if they exist
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'reporting_user') THEN
    EXECUTE 'DROP OWNED BY reporting_user';
    EXECUTE 'DROP ROLE reporting_user';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
    EXECUTE 'DROP OWNED BY app_user';
    EXECUTE 'DROP ROLE app_user';
  END IF;
END $$;

DROP TABLE IF EXISTS audit_log, orders, customers CASCADE;

-- 2. Tables
CREATE TABLE customers (
  customer_id  int PRIMARY KEY,
  full_name    text NOT NULL,
  email        text NOT NULL,
  city         text NOT NULL,
  loyalty_tier text NOT NULL
);

CREATE TABLE orders (
  order_id     int PRIMARY KEY,
  customer_id  int NOT NULL REFERENCES customers(customer_id),
  order_total  numeric(10,2) NOT NULL,
  status       text NOT NULL,
  created_at   timestamptz NOT NULL
);

CREATE TABLE audit_log (
  audit_id     bigint PRIMARY KEY,
  created_at   timestamptz NOT NULL,
  actor        text NOT NULL,
  action       text NOT NULL,
  entity       text NOT NULL,
  entity_id    int NOT NULL,
  details      jsonb NOT NULL
);

-- 3. Data (deterministic)
INSERT INTO customers
SELECT i,
       (ARRAY['Asha','Ben','Chloe','Dev','Ema','Farid','Gita','Hugo','Iris','Jon'])[1 + i % 10] || ' ' ||
       (ARRAY['Rao','Kim','Lopez','Patel','Novak','Silva','Mori','Shah','Weber','Okafor'])[1 + (i / 10) % 10],
       'customer' || lpad(i::text, 3, '0') || '@example.test',
       (ARRAY['Pune','Leeds','Austin','Lyon','Osaka'])[1 + i % 5],
       (ARRAY['bronze','silver','gold'])[1 + i % 3]
FROM generate_series(1, 500) AS i;

INSERT INTO orders
SELECT i,
       1 + (i * 7) % 500,
       round((10 + (i * 37) % 290)::numeric + 0.99, 2),
       (ARRAY['paid','shipped','delivered','refunded'])[1 + i % 4],
       now() - ((i % 300) * interval '1 day') - ((i % 600) * interval '1 minute')
FROM generate_series(1, 3000) AS i;

-- 200,000 audit rows spread evenly over the last 360 days.
-- The minute offset is at most 12 hours, so the 90-day count stays exact
-- for about 11 hours after seeding.
INSERT INTO audit_log
SELECT i,
       now() - ((i % 360) * interval '1 day') - ((i % 720) * interval '1 minute'),
       (ARRAY['web','checkout-worker','admin-panel','sync-job'])[1 + i % 4],
       (ARRAY['view','update','create','login','export'])[1 + i % 5],
       (ARRAY['order','customer','product','session'])[1 + i % 4],
       1 + i % 3000,
       jsonb_build_object(
         'ip', '10.0.' || (i % 250) || '.' || (i % 200),
         'user_agent', 'ShopClient/' || (1 + i % 9) || '.0 (synthetic)',
         'request_id', md5(i::text),
         'note', 'synthetic audit event for training use ' || md5((i * 3)::text)
       )
FROM generate_series(1, 200000) AS i;

ANALYZE;

-- 4. Roles
CREATE ROLE app_user LOGIN PASSWORD 'app_pw';
GRANT SELECT, INSERT, UPDATE, DELETE ON customers, orders, audit_log TO app_user;

CREATE ROLE reporting_user LOGIN PASSWORD 'report_pw';
GRANT ALL ON ALL TABLES IN SCHEMA public TO reporting_user;
